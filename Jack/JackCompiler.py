from ast import arg
import sys
import enum
import os
import os.path
from os import path
from .JackLexer import *


class SymbolTable:
    def __init__(self):
        self.table = {}
        self.kind_count = {"static": 0, "field":0, "argument":0, "var":0}
    def define(self, name, type, kind):
        self.table[name] = (type, kind, self.kind_count[kind])
        self.kind_count[kind] += 1
    def varCount(self, kind):
        count = 0
        for name in self.table:
            (_, k, _) = self.table[name]
            if k == kind:
                count += 1
        return count
    def kindOf(self,name):
        return self.table[name][1]
    def typeOf(self, name):
        return self.table[name][0]
    def indexOf(self, name):
        return self.table[name][2]
    def clear(self, is_method):
        self.table = {}
        argument_start_from = 1 if is_method else 0
        self.kind_count = {"static": 0, "field":0, "argument":argument_start_from, "var":0}
    def lookup(self, name):
        return name in self.table
    def __str__(self):
        out = "name\ttype\tkind\tidx\n"
        for n in self.table:
            out += f"{n}\t{self.table[n][0]}\t{self.table[n][1]}\t{self.indexOf(n)}\n"
        return out
        
class VMWriter:
    def __init__(self):
        self.labels_cnt = {}
        self.ir = ""

    def uniqueLabel(self, lbl, prefix ):
        if lbl not in self.labels_cnt:
            self.labels_cnt[lbl] = 0

        unique_lbl = f"{prefix}_{lbl}{self.labels_cnt[lbl]}"
        self.labels_cnt[lbl] += 1
        return unique_lbl
        
    def emitLabel(self, lbl):
        self.ir+=(f"label {lbl}\n")
    
    def emit(self, raw_instr):
        self.ir+=f"{raw_instr}\n"
    
    def emitIfGoto(self, lbl):
        self.ir+=(f"if-goto {lbl}\n")

    def emitGoto(self, lbl):
        self.ir+=(f"goto {lbl}\n")

    def emitSignature(self, class_name, function_name, num_params):
        self.ir+=(f"function {class_name}.{function_name} {num_params}\n")

    def emitConstructorSignature(self, class_name, routine_name, num_locals, num_fields):
        self.emitSignature(class_name, routine_name, num_locals)
        self.emitPush("constant", num_fields)
        self.emitFunctionCall("Memory", "alloc", 1)
        self.emitPop("pointer", 0)

    def emitMethodSignature(self, class_name, routine_name, num_locals):
        self.emitSignature(class_name, routine_name, num_locals)
        self.emitPush("argument", 0)
        self.emitPop("pointer", 0)

    def emitPush(self, kind, val):
        if kind == "var":
            segment = "local"
        elif kind == "field":
            segment = "this"
        else:
            segment = kind

        self.ir+=(f"push {segment} {val}\n")

    def emitPop(self, kind, idx):
        if kind == "var":
            segment = "local"
        elif kind == "field":
            segment = "this"
        else:
            segment = kind
        self.ir+=(f"pop {segment} {idx}\n")

    def emitReturn(self):
        self.ir+=("return\n")

    def emitArithmetic(self, op):
        if op == "+":
            self.emit("add")
        elif op == "-":
            self.emit("sub")
        elif op == "neg":
            self.emit("neg")
        elif op == "*":
            self.emitFunctionCall("Math", "multiply", 2)
        elif op == "<":
            self.emit("lt")
        elif op == ">":
            self.emit("gt")
        elif op == "/":
            self.emitFunctionCall("Math", "divide", 2)
        elif op == "~":
            self.emit("not")
        elif op == "&":
            self.emit("and")
        elif op == "|":
            self.emit("or")
        elif op == "=":
            self.emit("eq")
        else:
            print("Unknown operator")
    
    def emitFunctionCall(self, class_name, fun_name, num_params):
        if class_name:
            self.ir+=(f"call {class_name}.{fun_name} {num_params}\n")
        else:
            self.ir+=(f"call {fun_name} {num_params}\n")

    def emitString(self, const_str):
        self.emitPush("constant", len(const_str))
        self.emitFunctionCall("String", "new", 1)
        for c in const_str:
            self.emitPush("constant", ord(c))
            self.emitFunctionCall("String", "appendChar", 2)
        
    def emitBoolean(self, tok):
        if tok == "true":
            self.emitPush("constant", 0)
            self.emitArithmetic("~")
        else:
            self.emitPush("constant", 0)

    def __repr__(self):
        return self.ir
    
    def save(self, file_name):
        with open(file_name, "w") as f:
            print(self.ir, file=f)


class CompileEngine:
    ####################
    # Helper functions #
    ####################
    operators = ["+", "-", "*", "/", "&", "|", "<", ">", "="]

    def __init__(self, tokenizer):
        self.tokenizer = tokenizer
        self.classSymbolTable = SymbolTable()
        self.routineSymbolTable = SymbolTable()
        self.currentClass = ""
        self.emitter = VMWriter()
        self.isConstructor=False

    def lookup(self, name):
        table = None
        if self.routineSymbolTable.lookup(name):
            table = self.routineSymbolTable
        elif self.classSymbolTable.lookup(name):
            table = self.classSymbolTable
        else:
            return None
        
        return (table.typeOf(name), table.kindOf(name), table.indexOf(name))

    def next_token(self):
        self.cur_tok = self.tokenizer.next_token()

    def peek(self):
        return self.cur_tok.lexeme

    def syntax_error(self):
        print(
            f"Syntax error on token:{self.cur_tok.lexeme} at line {self.cur_tok.line}"
        )
        return False

    def compile_error(self, err):
        print(err)

    ##########################
    # Basic production rules #
    ##########################

    def keyword(self, lexeme, action=lambda x : x):
        """ Recognize a keyword """
        tok = self.cur_tok
        if tok.type == TokenType.keyword and tok.lexeme == lexeme:
            action(tok)
            self.next_token()
            return True
        return False

    def identifier(self, action=lambda x:x):
        """ Recognize an identifier"""
        tok = self.cur_tok
        if tok.type == TokenType.identifier:
            action(tok)
            self.next_token()
            return True
        return False

    def symbol(self, val):
        """ Recognize a symbol """
        tok = self.cur_tok
        if tok.type == TokenType.symbol and tok.lexeme == val:
            self.next_token()
            return True
        return False

    def type(self, action=lambda x:x):
        """" Recognize a type """
        if self.cur_tok.type == TokenType.keyword and self.cur_tok.lexeme in [
            "int",
            "char",
            "boolean",
        ]:
            action(self.cur_tok)
            self.next_token()
            return True
        return self.identifier(action)

    def returnType(self):
        """" Recognize a return type """
        return self.keyword("void") or self.type()

    def className(self, action=lambda x:x):
        """" Recognize a class name"""
        return self.identifier(action)

    def subroutineName(self, action=lambda x:x):
        """" Recognize a subroutine name"""
        return self.identifier(action)

    def varName(self, action=lambda x:x):
        """" Recognize a variable name"""
        return self.identifier(action)

    ####################
    # Production rules #
    ####################

    def paramList(self, action1 = lambda x:x, action2 = lambda x:x):
        """ Recognize ((type varName)(',' type varName)*)?"""

        if self.type(action1):

            if not self.varName(action2):
                return self.syntax_error()

            if self.symbol(","):
                self.paramList(action1, action2)

            return True

        return False

    def additionalExprs(self, action=lambda x:x):
        if self.symbol(","):
            action(self.cur_tok)
            self.expr()
            self.additionalExprs(action)

    def exprList(self, action = lambda x:x):
        if self.cur_tok.lexeme == ")":
            return True

        action(self.cur_tok)
        if self.expr():
            self.additionalExprs(action)
        return True

    def subroutineCall(self, lex0, lex1):
        """ subroutineCall: subroutineName '(' expressionList ')' | (className | varName) '.' subroutineName '(' expressionList ')' """

        arg_count = 0
        function_name = ""
        def inc_arg_count(t):
            nonlocal arg_count
            arg_count += 1
        def set_function_name(tok):
            nonlocal function_name
            function_name = tok.lexeme

        if lex1 == "(":
            # self argument
            arg_count += 1 

            # Push this on the stack
            if self.isConstructor:
                self.emitter.emitPush("pointer", 0)
            else:
                self.emitter.emitPush("argument", 0)

            self.exprList(inc_arg_count)
            if not self.symbol(")"):
                return self.syntax_error()
            self.emitter.emitFunctionCall(self.currentClass, lex0, arg_count)
            return True
        elif lex1 == ".":
            if not self.identifier(set_function_name):
                return self.syntax_error()

            if not self.symbol("("):
                return self.syntax_error()


            # if lex0 is a variable of a Class, then call
            # Class.fun_name
            class_name = lex0
            record = self.lookup(lex0)
            if record:
                class_name = record[0]
                self.emitter.emitPush(record[1], record[2])
                arg_count += 1

            self.exprList(inc_arg_count)
            if not self.symbol(")"):
                return self.syntax_error()

            self.emitter.emitFunctionCall(class_name, function_name, arg_count)

            return True
        else:
            return self.syntax_error()

    def term(self):
        """term : integerConstant | stringConstant | keywordConstant | varName | varName '[' expression ']' |
        subroutineCall | '(' expression ')' | unaryOpTerm"""
        tok = self.cur_tok
        if tok.type == TokenType.int_const:
            self.emitter.emitPush("constant", tok.lexeme)
            self.next_token()
            return True
        elif tok.type == TokenType.str_const:
            self.emitter.emitString(tok.lexeme)
            self.next_token()
            return True
        elif tok.lexeme == "this":
            self.emitter.emitPush("pointer", 0)
            self.next_token()
            return True
        elif tok.lexeme == "(":
            self.symbol("(")
            self.expr()
            if not self.symbol(")"):
                return self.syntax_error()
            return True
        elif tok.lexeme in ["true", "false"]:
            self.emitter.emitBoolean(tok.lexeme)
            self.next_token()
            return True
        elif tok.lexeme in ["-", "~"]:
            op = "neg" if tok.lexeme == "-" else "~"
            self.next_token()
            if not self.term():
                return self.syntax_error()
            self.emitter.emitArithmetic(op)
            return True
        elif tok.type == TokenType.identifier:
            self.next_token()
            tok1 = self.cur_tok
            if tok1.lexeme in ["(", "."]:
                self.next_token()
                # subroutine call
                if not self.subroutineCall(tok.lexeme, tok1.lexeme):
                    return self.syntax_error()
            elif tok1.lexeme == "[":
                # array
                (t, k, p) = self.lookup(tok.lexeme)
                self.emitter.emitPush(k, p)

                self.symbol("[")
                if not self.expr():
                    return self.syntax_error()

                if not self.symbol("]"):
                    return self.syntax_error()

                self.emitter.emitArithmetic("+")

                # set that
                self.emitter.emitPop("pointer", 1)
                # push that[0] onto the stack
                self.emitter.emitPush("that", 0)
            else:
                (t, k, p) = self.lookup(tok.lexeme)
                self.emitter.emitPush(k, p)
            
            return True

        else:
            return self.syntax_error()

    def exprPrime(self):
        if self.cur_tok.lexeme in CompileEngine.operators:
            op = self.cur_tok.lexeme
            self.symbol(self.cur_tok.lexeme)
            if not self.term():
                return self.syntax_error()
            self.emitter.emitArithmetic(op)
            self.exprPrime()
        return False

    def expr(self):
        """ expression : term (op term)* """
        if not self.term():
            return self.syntax_error()

        # Optional part of the expression (also avoids left recursion)
        self.exprPrime()

        return True

    def letStmt(self):
        """ letStatement : 'let' varName ('[' expression ']')? '=' expression ';' """
        var_name = ""
        def set_var_name(t):
            nonlocal var_name
            var_name = t.lexeme
        

        if not self.varName(set_var_name):
            return self.syntax_error()
        (t, k, p) = self.lookup(var_name)

        isArray = False
        if self.symbol("["):
            isArray = True
            self.emitter.emitPush(k, p)

            if not self.expr():
                return self.syntax_error()

            if not self.symbol("]"):
                return self.syntax_error()

            # add
            self.emitter.emitArithmetic("+")

        if not self.symbol("="):
            return self.syntax_error()
        if not self.expr():
            return self.syntax_error()
        if not self.symbol(";"):
            return self.syntax_error()

        if isArray:
            # Emit finalization sequence for arrays
            self.emitter.emitPop("temp", 0)
            self.emitter.emitPop("pointer", 1)
            self.emitter.emitPush("temp", 0)
            self.emitter.emitPop("that", 0)
        else:
            self.emitter.emitPop(k, p)

        return True

    def ifStmt(self):
        """" ifStatement: 'if' '(' expression ')' '{' statements '}' """

        # Generate unique labels for if-then-else
        if_end_lbl = self.emitter.uniqueLabel("IF_END", self.currentClass)
        if_false_lbl = self.emitter.uniqueLabel("IF_FALSE", self.currentClass)
        if_true_lbl = self.emitter.uniqueLabel("IF_TRUE", self.currentClass)

        if not self.symbol("("):
            return self.syntax_error()
        if not self.expr():
            return self.syntax_error()
        if not self.symbol(")"):
            return self.syntax_error()
        if not self.symbol("{"):
            return self.syntax_error()

        # if there is true on the stack go-to true_label
        self.emitter.emitIfGoto(if_true_lbl)
        # Go to false label
        self.emitter.emitGoto(if_false_lbl)

        self.emitter.emitLabel(if_true_lbl)
        self.statementList()

        # Goto end_lable
        self.emitter.emitGoto(if_end_lbl)


        if not self.symbol("}"):
            return self.syntax_error()

        self.emitter.emitLabel(if_false_lbl)

        if self.keyword("else"):
            if not self.symbol("{"):
                return self.syntax_error()

            self.statementList()

            if not self.symbol("}"):
                return self.syntax_error()

        self.emitter.emitLabel(if_end_lbl)
        return True

    def whileStmt(self):
        """ whileStatement: 'while' '(' expression ')' '{' statements '}' """
        while_exp = self.emitter.uniqueLabel("WHILE_EXP", self.currentClass)
        while_end = self.emitter.uniqueLabel("WHILE_END", self.currentClass)

        if not self.symbol("("):
            return self.syntax_error()

        self.emitter.emitLabel(while_exp)
        if not self.expr():
            return self.syntax_error()
        self.emitter.emit("not")
        self.emitter.emitIfGoto(while_end)

        if not self.symbol(")"):
            return self.syntax_error()

        if not self.symbol("{"):
            return self.syntax_error()

        self.statementList()

        if not self.symbol("}"):
            return self.syntax_error()

        self.emitter.emitGoto(while_exp)
        self.emitter.emitLabel(while_end)

        return True

    def doStmt(self):
        """ doStatement : 'do' subroutineCall ';' """
        lex0 = self.cur_tok.lexeme
        self.next_token()

        lex1 = self.cur_tok.lexeme
        self.next_token()
        if not self.subroutineCall(lex0, lex1):
            return self.syntax_error()

        if not self.symbol(";"):
            return self.syntax_error()
        self.emitter.emitPop("temp", 0)

        return True

    def retStmt(self):
        """ returnStatement: 'return' expression? ';' """

        if not self.cur_tok.lexeme == ";":
            self.expr()
        else:
            self.emitter.emitPush("constant", 0)

        if not self.symbol(";"):
            return self.syntax_error()

        self.emitter.emitReturn()

        return True

    def varNameList(self, action=lambda x:x):
        if self.symbol(","):
            if not self.varName(action):
                return self.syntax_error()
            self.varNameList(action)
            return True
        return False

    def varDecList(self):
        type = ""
        names = []
        def save_type(toc):
            nonlocal type  
            type = toc.lexeme
        def save_names(toc):
            nonlocal names 
            names.append(toc.lexeme)

        if self.keyword("var"):
            if not self.type(save_type):
                return self.syntax_error()
            if not self.varName(save_names):
                return self.syntax_error()
            self.varNameList(save_names)
            if not self.symbol(";"):
                return self.syntax_error()
            for name in names:
                self.routineSymbolTable.define(name, type, "var")


            self.varDecList()
            return True
        return False

    def statementList(self):
        """" statements : statement* """
        if self.keyword("let"):
            if not self.letStmt():
                return self.syntax_error()
            self.statementList()
            return True
        elif self.keyword("if"):
            if not self.ifStmt():
                return self.syntax_error()
            self.statementList()
            return True
        elif self.keyword("while"):
            if not self.whileStmt():
                return self.syntax_error()
            self.statementList()
            return True
        elif self.keyword("do"):
            if not self.doStmt():
                return self.syntax_error()
            self.statementList()
            return True
        elif self.keyword("return"):
            if not self.retStmt():
                return self.syntax_error()
            self.statementList()
            return True
        else:
            return False

    # Inlining this production to get access to the number of variables in the body
    #def subroutineBody(self):
    #    """ subroutineBody : '{' varDec* statements '}' """
    #    if not self.symbol("{"):
    #        return self.syntax_error()

    #    self.varDecList()
    #    self.statementList()

    #    if not self.symbol("}"):
    #        return self.syntax_error()
    #    return True

    def varNames(self, action=None):
        if self.varName(action):
            if self.symbol(","):
                self.varNames(action)
            return True
        return False

    def classVarDec(self):
        """ classVarDec : ('static' | 'field') type varName (',' varName)* ';' """

        type = ""
        kind = ""
        names = []
        def save_kind(tok):
            nonlocal kind
            kind = tok.lexeme
        def save_type(toc):
            nonlocal type  
            type = toc.lexeme
        def save_names(toc):
            nonlocal names 
            names.append(toc.lexeme)

        # Rule: add variable to the Symbol table
        if self.keyword("static", save_kind) or self.keyword("field", save_kind):
            if not self.type(save_type):
                return self.syntax_error()

            if not self.varNames(save_names):
                return self.syntax_error()

            if not self.symbol(";"):
                return self.syntax_error()
            
            for name in names:
                self.classSymbolTable.define(name, type, kind)
            
            self.classVarDec()

            return True

        return False

    def subroutineDec(self):
        """ subroutineDec : ('constructor' | 'function' | 'method') ('void' | type) subroutineName '(' parameterList ')' """

        is_method = False
        #is_constructor = False
        routine_name = ""
        types = []
        names = []
        
        def init(t):
            nonlocal is_method
            if t.lexeme == "constructor":
                is_method = False
                self.isConstructor = True
            elif t.lexeme == "method":
                is_method = True
                self.isConstructor = False
            else:
                is_method = False
                self.isConstructor = False

        def set_routine_name(t):
            nonlocal routine_name
            routine_name = t.lexeme

        def save_types(toc):
            nonlocal types  
            types.append(toc.lexeme)

        def save_names(toc):
            nonlocal names 
            names.append(toc.lexeme)

        if (
            self.keyword("constructor", init)
            or self.keyword("function", init)
            or self.keyword("method", init)
        ):
            self.routineSymbolTable.clear(is_method)

            if not self.returnType():
                return self.syntax_error()

            if not self.subroutineName(set_routine_name):
                return self.syntax_error()

            if not self.symbol("("):
                return self.syntax_error()

            self.paramList(save_types, save_names)

            for i in range(len(names)):
                self.routineSymbolTable.define(names[i], types[i], "argument")

            if not self.symbol(")"):
                return self.syntax_error()


    
            # Inlining this production: the issue is that we need the number of variables
            # to emit the signature of the function
            # subroutineBody : '{' varDec* statements '}'
            if not self.symbol("{"):
                return self.syntax_error()

            # varDecList does not generate any IR, it only store identifiers in the symbol table
            self.varDecList()

            # Now we can emit the signature of the function
            num_locals = self.routineSymbolTable.varCount("var")
            if self.isConstructor:
                num_fields = self.classSymbolTable.varCount("field")
                self.emitter.emitConstructorSignature(self.currentClass, routine_name, num_locals, num_fields)
            elif is_method:
                self.emitter.emitMethodSignature(self.currentClass, routine_name, num_locals)
            else: # if function
                self.emitter.emitSignature(self.currentClass, routine_name, num_locals)


            self.statementList()

            if not self.symbol("}"):
                return self.syntax_error()

            self.subroutineDec()

            return True

        return False

    def compileClass(self):
        """ class: 'class' className '{' classVarDec* subroutineDec* '}' """

        def set_class_name(t):
            self.currentClass = t.lexeme

        # Match the rule 'class'
        if not self.keyword("class"):
            return self.syntax_error()

        if not self.className(set_class_name):
            return self.syntax_error()

        if not self.symbol("{"):
            return self.syntax_error()

        self.classVarDec()
        self.subroutineDec()

        if not self.symbol("}"):
            return self.syntax_error()

        return True

    def parse(self):
        """ Start the parsing process """

        self.next_token()
        self.classSymbolTable.clear(False)
        res = self.compileClass()
        return res


if __name__ == "__main__":
    """ Compiler driver """

    jack_files = []
    for a in sys.argv:
        # if a is a folder
        if path.isdir(a):
            for file_name in os.listdir(a):
                if file_name.endswith("jack"):
                    jack_files.append(os.path.join(a, file_name))

        # add all the jack files in the folder
        if a.endswith("jack"):
            jack_files.append(a)

    for jack_file in jack_files:
        vm_file = jack_file.replace("jack", "vm")
        f = open(vm_file, "w")
        tokenizer = JackTokenizer(jack_file)
        analyzer = CompileEngine(tokenizer)
        analyzer.parse()
        analyzer.emitter.save(vm_file)
