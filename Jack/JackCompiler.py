import sys
import enum
import os
import os.path
from os import path

class TokenType(enum.Enum):
    KEYWORD = 0
    SYMBOL = 1
    INTEGER_CONSTANT = 2
    STRING_CONSTANT = 3
    IDENTIFIER = 4
    PRIMITIVE_TYPE = 5
    CLASS_TYPE = 6
    ERROR =100


def RepresentsInt(s):
    try: 
        int(s)
        return True
    except ValueError:
        return False

def EmitKeyword(tok):
    pass

def EmitString(tok):
    pass

def EmitInt(tok):
    pass 

def EmitIdentifier(tok):
    pass 

def EmitSymbol(tok):
    if tok == ">":
        tok = "&gt;"
    if tok == "<":
        tok = "&lt;"
    if tok == "&":
        tok = "&amp;"

    pass 

def EmitOp(tok):
    pass

def EmitType(tok, typ):
    is_primitive_type = tok in ["int", "char", "boolean"]
    is_class = typ == "identifier"
    if is_primitive_type:
        EmitKeyword(tok)
    else:
        EmitIdentifier(tok)

def JackTokenizer(path):
   keywords = ['class', 'constructor', 'function', 'method',
                    'field', 'static', 'var', 'int', 'char', 'boolean', 'void', 
                    'true', 'false', 'null', 'this', 'let', 'do', 'if', 'else',
                    'while', 'return']

   symbols = ['{', '}', '(', ')', '[', ']', '.', ',', ';', '+', '-', '*', '/', '&', '|', '<', '>', '=', '-', '~']

   token_type = None

   f = open(path)

   tokens = []
   nocomments = ""
   state = "normal"
   for l in f:
       for c in l:
           if c == '/' and state == "normal":
               state = "could_comment"
               continue

           if c == '*' and state == "could_comment":
               state = "multiline"
               continue

           if c != '/' and state == "could_comment":
               nocomments += '/'
               nocomments += c
               state = "normal"
               continue

           if c == '/' and state == "could_comment":
               state = "comment"

           if c == '\n' and state == "comment":
               nocomments += '\n'
               state = "normal"
               continue

           if c == '*' and state == "multiline":
               state = "could_end_multiline"
               continue

           if c == "/" and state == "could_end_multiline":
               state = "normal"
               continue

           if c != "/" and state == "could_end_multiline":
               state = "multiline"
               continue

           if state == "normal":
               nocomments += c


   state = "noword"
   word = ""
   for c in nocomments:
       if c=="\"" and state=="noword":
           state="string"
           continue

       if c=="\"" and state=="string":
           state="noword"
           tokens.append((word, "str_const"))
           word = ""
           continue

       if state == "string":
           word += c
           continue

       if (c == "\n" or c == ' ' or c == "\t") and state=="noword":
           continue

       if (c in symbols ) and state=="noword":
           tokens.append((c, "symbol"))
           continue

       if (c == '\n' or c == ' ' or c == "\t") and state == "word":
           if word in keywords:
               tokens.append((word,"keyword"))
           elif RepresentsInt(word):
               tokens.append((word,"int_const"))
           else:
               tokens.append((word,"identifier"))
           state = "noword"
           word = ""
           continue

       if (c  in symbols) and state=="word":
           if word in keywords:
               tokens.append((word,"keyword"))
           elif RepresentsInt(word):
               tokens.append((word,"int_const"))
           else:
               tokens.append((word,"identifier"))
           tokens.append((c,"symbol"))
           state = "noword"
           word = ""
           continue
      
       state = "word"
       word += c


   return tokens

class VMWriter:

    def __init__(self):
        self.labels_cnt = {}

    def uniqueLabel(self, lbl):
        if lbl not in self.labels_cnt:
            self.labels_cnt[lbl] = 0

        unique_lbl = f"{lbl}{self.labels_cnt[lbl]}"
        self.labels_cnt[lbl] += 1
        return unique_lbl
        
    def emitLabel(self, lbl):
        print(f"label {lbl}")
    
    def emit(self, raw_instr):
        print(raw_instr)
    
    def emitIfGoto(self, lbl):
        print(f"if-goto {lbl}")

    def emitGoto(self, lbl):
        self.emit(f"goto {lbl}")

    def emitSignature(self, class_name, function_name, num_params):
        print(f"function {class_name}.{function_name} {num_params}")

    def emitPush(self, segment, val):
        print(f"push {segment} {val}")

    def emitPop(self, segment, idx):
        print(f"pop {segment} {idx}")

    def emitReturn(self):
        print("return")

    def emitArithmetic(self, op):
        if op == "+":
            print("add")
        elif op == "-":
            print("neg")
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
        elif op == "=":
            self.emit("eq")
    
    def emitFunctionCall(self, class_name, fun_name, num_params):
        if class_name:
            print(f"call {class_name}.{fun_name} {num_params}")
        else:
            print(f"call {fun_name} {num_params}")

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



class CompileEngine:

    def __init__(self, tokens):
        self.tokens = tokens

        self.subroutineSymbolTable = {}
        self.loc_cnt = 0

        self.classSymbolTable = {}
        self.class_cnt = {"this": 0, "static" : 0}


        self.emitter = VMWriter()
        self.cur_tok = 0
        self.cls = ""

    def advance(self):
        next_tok = self.tokens[self.cur_tok]
        self.cur_tok += 1
        return next_tok

    def current_token(self):
        return self.tokens[self.cur_tok]
    
    def hasMoreTokens(self):
        return self.cur_tok < len(self.tokens)

    def keyword(self,tok):
        (cur_tok, token_type) = self.advance()
        if token_type != "keyword" or cur_tok != tok:
            self.cur_tok -= 1
            raise ValueError("Error")
        EmitKeyword(cur_tok)

    def symbol(self,tok):
        (cur_tok, token_type) = self.advance()
        if token_type != "symbol" or cur_tok != tok:
            raise ValueError("Error")
        EmitSymbol(cur_tok)

    def identifier(self):
        (cur_tok, token_type) = self.advance()
        if token_type != "identifier":
            raise ValueError("Error")
        return cur_tok
        

    def is_type(self, tok, typ):
        if (tok in ["int", "char", "boolean"]):
            return TokenType.PRIMITIVE_TYPE
        elif typ == "identifier":
            return TokenType.CLASS_TYPE
        else:
            return TokenType.ERROR

    def atype(self):
        (cur_tok, token_type) = self.advance()
        return cur_tok
        #is_primitive_type = cur_tok in ["int", "char", "boolean"]
        #is_class = token_type == "identifier"
        #if not (is_primitive_type or is_class):
        #    self.cur_tok -= 1
        #    raise ValueError("Error")
        #if is_primitive_type:
        #    EmitKeyword(cur_tok)
        #else:
        #    EmitIdentifier(cur_tok)

    def stringConstant(self):
        tok, typ = self.advance()
        if typ != "str_const":
            self.cur_tok -= 1
            raise ValueError("error")

    def integerConstant(self):
        tok, typ = self.advance()
        if typ != "int_const":
            self.cur_tok -= 1
            raise ValueError("error")

    def op(self):
        tok, typ = self.advance()
        is_op  = tok in ['+', '-', '*', '/', '&', '|', '<', '>', '=', '-']
        if not is_op:
            self.cur_tok -= 1
            raise ValueError("Error")

    def unaryOp(self):
        tok, typ = self.advance()
        is_op  = tok in ['-', '~']
        if not is_op:
            self.cur_tok -= 1
            raise ValueError("Error")

    def varName(self):
        return self.identifier()

    def className(self):
        self.identifier()

    def subroutineName(self):
        return self.identifier()

    def classVarDec(self, storage_tok):
        if storage_tok == "field":
            segment = "this"
        else:
            segment = "static"

        typ = self.atype()
        name = self.varName()

        self.classSymbolTable[name] = (typ, segment, self.class_cnt[segment])
        self.class_cnt[segment] += 1

        tok,typ = self.advance()
        while tok == ",":
            name = self.varName()
            self.classSymbolTable[name] = (typ, segment, self.class_cnt[segment])
            self.class_cnt[segment] += 1
            tok,typ = self.advance()

        self.cur_tok -= 1
        self.symbol(';')

    def returnType(self):
        tok,typ = self.advance()
        is_primitive_type = tok in ["int", "char", "boolean"]
        is_class = typ == "identifier"
        is_void = tok == "void"

        if is_void:
            EmitKeyword("void")
        elif is_class:
            EmitIdentifier(tok)
        elif is_primitive_type:
            EmitKeyword(tok)
        else:
            raise ValueError("Error")

    def paramList(self, arg_cnt):
        tok,typ = self.advance()

        if tok in ["int", "char", "boolean"] or typ == "identifier":
            name  = self.varName()
            self.subroutineSymbolTable[name] = (tok, "argument", arg_cnt)
            arg_cnt += 1

            tok,typ = self.advance()
            while tok == ",":
                typ = self.atype()
                name = self.varName()

                self.subroutineSymbolTable[name] = (typ, "argument", arg_cnt)
                arg_cnt += 1

                tok,typ = self.advance()
            self.cur_tok -= 1
        else:
            self.cur_tok -= 1

        return arg_cnt

    def varDec(self):
        typ = self.atype()
        name = self.varName()

        self.subroutineSymbolTable[name] = (typ, "local", self.loc_cnt)
        self.loc_cnt += 1

        tok,typ = self.advance()
        while tok == ",":
            name = self.varName()
            self.subroutineSymbolTable[name] = (typ, "local", self.loc_cnt)
            self.loc_cnt += 1

            tok,typ = self.advance()

        self.cur_tok -= 1
        self.symbol(";")
    
    def lookup(self, name):
        if name in self.subroutineSymbolTable:
            typ = self.subroutineSymbolTable[name][0]
            segment = self.subroutineSymbolTable[name][1]
            pos = self.subroutineSymbolTable[name][2]
        elif name in self.classSymbolTable:
            typ = self.classSymbolTable[name][0]
            segment = self.classSymbolTable[name][1]
            pos = self.classSymbolTable[name][2]
        else:
            typ = None
            segment = None
            pos = None

        return (segment, pos, typ)

    def letStmt(self):
        name = self.varName()
        segment, pos, _ = self.lookup(name)

        tok, typ = self.advance()

        if tok == "[":
            #arr[expression1] = expression2

            # push arr
            self.emitter.emitPush(segment, pos)

            # push expression1
            self.expr()
            self.symbol("]")

            # add
            self.emitter.emitArithmetic("+")
            self.symbol("=")

            # push expression2
            self.expr()

            self.emitter.emitPop("temp", 0)
            self.emitter.emitPop("pointer", 1)
            self.emitter.emitPush("temp", 0)
            self.emitter.emitPop("that", 0)

        else:
            self.cur_tok -= 1
            self.symbol("=")
            self.expr()
            self.emitter.emitPop(segment, pos)

        self.symbol(";")

    def ifStmt(self):
        if_end_lbl = self.emitter.uniqueLabel("IF_END")
        if_false_lbl = self.emitter.uniqueLabel("IF_FALSE")
        if_true_lbl = self.emitter.uniqueLabel("IF_TRUE")

        self.symbol("(")
        self.expr()
        self.symbol(")")
        self.symbol("{")

        self.emitter.emitIfGoto(if_true_lbl)
        self.emitter.emitGoto(if_false_lbl)
        self.emitter.emitLabel(if_true_lbl)
        self.statements()
        self.emitter.emitGoto(if_end_lbl)
        self.symbol("}")
        tok, typ = self.advance()
        self.emitter.emitLabel(if_false_lbl)
        if tok == "else":
            self.symbol("{")
            self.statements()
            self.symbol("}")
        else:
            self.cur_tok -= 1
        self.emitter.emitLabel(if_end_lbl)


    def whileStmt(self):
        while_exp = self.emitter.uniqueLabel("WHILE_EXP")
        while_end = self.emitter.uniqueLabel("WHILE_END")

        self.symbol("(")
        self.emitter.emitLabel(while_exp)
        self.expr()
        self.emitter.emit("not")
        self.emitter.emitIfGoto(while_end)
        self.symbol(")")
        self.symbol("{")
        self.statements()
        self.symbol("}")
        self.emitter.emitGoto(while_exp)
        self.emitter.emitLabel(while_end)

    def doStmt(self):
        self.subroutineCall()
        self.emitter.emitPop("temp", 0)
        self.symbol(';')

    def retStmt(self):
        tok, typ = self.advance()
        if tok == ";":
            self.emitter.emitPush("constant", 0)
        else:
            self.cur_tok -= 1
            self.expr()
            self.symbol(";")
        self.emitter.emitReturn()

    def expr(self):
        self.term()
        tok, typ = self.advance()
        while tok in ["+", "-", "*", "/", "&", "|", "<", ">", "="]:
            self.term()
            self.emitter.emitArithmetic(tok)
            tok, typ = self.advance()
        self.cur_tok -= 1

    def term(self):
        tok, typ = self.advance()
        if typ == "int_const":
            self.emitter.emitPush("constant", tok)
        elif typ == "str_const":
            self.emitter.emitString(tok)
        elif tok == "this":
            self.emitter.emitPush("pointer", 0)
        elif tok == "(":
            self.expr()
            self.symbol(")")
        elif tok in ["true", "false"]:
            self.emitter.emitBoolean(tok)
        elif tok in  ['-', '~']:
            self.term()
            self.emitter.emitArithmetic(tok)
        elif typ == "identifier":
            tok1, typ1 = self.advance()
            if tok1 in ["(", "."]:
                self.cur_tok -= 2
                self.subroutineCall()
            elif tok1 == '[':
                # arr[i]
                (segment, pos, _) = self.lookup(tok)
                # push arr
                self.emitter.emitPush(segment, pos)
                # push i
                self.expr()
                self.symbol("]")
                # add
                self.emitter.emitArithmetic("+")
                # set that
                self.emitter.emitPop("pointer", 1)
                # push that[0] onto the stack
                self.emitter.emitPush("that", 0)
            else:
                # variable
                self.cur_tok -= 1
                (segment, pos, _) = self.lookup(tok)
                self.emitter.emitPush(segment, pos)

    def exprList(self):
        tok, typ = self.advance()
        if tok == ")":
            return 0
        else:
            self.cur_tok -= 1
            self.expr()
            params = 1
            tok, typ = self.advance()
            while tok == ",":
                self.expr()
                params += 1
                tok, typ = self.advance()
            self.cur_tok -= 1
            self.symbol(")")
            return params

    def subroutineCall(self):
        identifier = self.identifier()
        tok1, typ1 = self.advance()

        if tok1 == "(":
            self.emitter.emitPush("pointer", 0)
            num_params = self.exprList() + 1
            self.emitter.emitFunctionCall(self.cls, identifier, num_params)
        elif tok1 == ".":
            fun_name = self.subroutineName()
            self.symbol("(")
            (segment, pos, typ) = self.lookup(identifier)

            num_params = 0

            if segment: # method call
                self.emitter.emitPush(segment, pos)
                class_name = typ
                num_params += 1
            else: # function call
                class_name = identifier

            num_params += self.exprList()
            self.emitter.emitFunctionCall(class_name, fun_name, num_params)
        

    def statements(self):
        tok,typ = self.advance()
        while tok in ["let", "if", "while", "do", "return"]:
            if tok == "let":
                self.letStmt()
            elif tok == "if":
                self.ifStmt()
            elif tok == "while":
                self.whileStmt()
            elif tok == "do":
                self.doStmt()
            elif tok == "return":
                self.retStmt()
            tok,typ = self.advance()
        self.cur_tok -= 1


    def subroutineBody(self):
        self.statements()
        #self.retStmt()
        self.symbol("}")


    def subroutineHeader(self, kind):
        self.subroutineName()

    def subroutineDec(self, kind):
        self.subroutineSymbolTable = {}
        self.loc_cnt = 0

        ret_type = self.returnType()
        fname = self.subroutineName()

        if kind in ["method", "constructor"] :
            arg_cnt = 1
        else:
            arg_cnt = 0
        
        self.symbol('(')
        arg_cnt = self.paramList(arg_cnt)
        self.symbol(')')
        self.symbol("{")


        # Variable declaration (only fill symbol table)
        tok,typ = self.advance()
        while tok == "var":
            self.varDec()
            tok,typ = self.advance()
        self.cur_tok -= 1

        # emit the signature
        num_locals = len(self.subroutineSymbolTable)
        self.emitter.emitSignature(self.cls, fname, num_locals)

        if kind == "constructor":
            num_fields = 0
            for v in self.classSymbolTable.values():
                if v[1]== "this":
                    num_fields += 1
                
            self.emitter.emitPush("constant", num_fields)
            self.emitter.emitFunctionCall("Memory", "alloc", 1)
            self.emitter.emitPop("pointer", 0)

        if kind == "method":
            self.emitter.emitPush("argument", 0)
            self.emitter.emitPop("pointer", 0)

        self.subroutineBody()
        if ret_type == "void":
            self.emitter.emitPush("constant", 0)


    def compileClass(self):
        self.keyword("class")

        self.classSymbolTable = {}
        self.class_cnt = {"this" : 0, "static" : 0}

        (cur_tok, token_type) = self.advance()
        if token_type == "identifier":
            self.cls = cur_tok

        self.symbol("{")

        #classVarDec* (to store into the class symbol table)
        tok,typ = self.advance()
        while tok in ["static", "field"]:
            self.classVarDec(tok)
            tok, typ = self.advance()
        self.cur_tok-=1

        tok,typ = self.advance()
        while tok in ["constructor", "function", "method", "void"]:
            self.subroutineDec(tok)
            tok,typ = self.advance()

        self.cur_tok-=1
        self.symbol("}")


    def parse(self):
        self.compileClass()


if __name__ == "__main__":
    jack_files = []
    for a in sys.argv:
        #if a is a folder
        if path.isdir(a):
            for file_name in os.listdir(a):
                if file_name.endswith("jack"):
                    jack_files.append(os.path.join(a,file_name))


        # add all the jack files in the folder
        # else
        if a.endswith("jack"):
            jack_files.append(a)

    for jack_file in jack_files:
        vm_file = jack_file.replace("jack", "vm")

        f = open(vm_file, "w")

        tokens = JackTokenizer(jack_file)
        analyzer = CompileEngine(tokens)
        orig_stdout = sys.stdout
        sys.stdout = f
        analyzer.parse()
        sys.stdout = orig_stdout
