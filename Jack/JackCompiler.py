import sys
import enum
import os
import os.path
from os import path
from .JackLexer import *


class CompileEngine:
    ####################
    # Helper functions #
    ####################
    operators = ["+", "-", "*", "/", "&", "|", "<", ">", "="]

    def __init__(self, tokenizer):
        self.tokenizer = tokenizer

    def next_token(self):
        self.cur_tok = self.tokenizer.next_token()

    def peek(self):
        return self.cur_tok.lexeme

    def syntax_error(self):
        print(f"Syntax error on token:{self.cur_tok.lexeme} at line {self.cur_tok.line}")
        return False
    


    ##########################
    # Basic production rules #
    ##########################

    def keyword(self, lexeme):
        """ Recognize a keyword """
        tok = self.cur_tok
        if tok.type == TokenType.keyword and tok.lexeme == lexeme:
            self.next_token()
            return True
        return False

    def identifier(self):
        """ Recognize a keyword """
        tok = self.cur_tok
        if tok.type == TokenType.identifier:
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

    def type(self):
        """" Recognize a type """
        if self.cur_tok.type == TokenType.keyword and self.cur_tok.lexeme in ["int", "char", "boolean"]:
            self.next_token()
            return True
        return self.identifier()

    def returnType(self):
        """" Recognize a return type """
        return self.keyword("void") or self.type()
    
    def className(self):
        """" Recognize a class name"""
        return self.identifier()

    def subroutineName(self):
        """" Recognize a subroutine name"""
        return self.identifier()

    def varName(self):
        """" Recognize a variable name"""
        return self.identifier()
        
    ####################
    # Production rules #
    ####################

    def paramList(self):
        """ Recognize ((type varName)(',' type varName)*)?"""

        if self.type():

            if not self.varName():
                return self.syntax_error()

            if self.symbol(","):
                self.paramList()

            return True

        return False

    
    def additionalExprs(self):
        if self.symbol(","):
            self.expr()
            self.additionalExprs()

    def exprList(self):
        if self.cur_tok.lexeme == ")":
            return True

        if self.expr():
            self.additionalExprs()
        return True

    def subroutineCall(self, lex1):
        """ subroutineCall: subroutineName '(' expressionList ')' | (className | varName) '.' subroutineName '(' expressionList ')' """

        if lex1 == "(":
            self.exprList()
            if not self.symbol(")"):
                return self.syntax_error()
            return True
        elif lex1 == ".":
            if not self.identifier():
                return self.syntax_error()

            if not self.symbol("("):
                return self.syntax_error()

            self.exprList()

            if not self.symbol(")"):
                return self.syntax_error()

            return True
        else:
            return self.syntax_error()
            

    def term(self):
        """ term : integerConstant | stringConstant | keywordConstant | varName | varName '[' expression ']' |
                   subroutineCall | '(' expression ')' | unaryOpTerm """
        tok = self.cur_tok
        if tok.type == TokenType.int_const:
            self.next_token()
            return True
        elif tok.type == TokenType.str_const:
            self.next_token()
            return True
        elif tok.lexeme == "this":
            self.next_token()
            return True
        elif tok.lexeme == "(":
            self.symbol("(")
            self.expr()
            if not self.symbol(")"):
                return self.syntax_error()
            return True
        elif tok.lexeme in ["true", "false"]:
            self.next_token()
            return True
        elif tok.lexeme in  ['-', '~']:
            self.next_token()
            if not self.term():
                return self.syntax_error()
            return True
        elif tok.type == TokenType.identifier:
            self.next_token()
            tok1 = self.cur_tok
            if tok1.lexeme in ["(", "."]:
                self.next_token()
                # subroutine call
                if not self.subroutineCall(tok1.lexeme):
                    return self.syntax_error()
            elif tok1.lexeme == '[':
                # array
                self.symbol("[")
                if not self.expr():
                    return self.syntax_error()

                if not self.symbol("]"):
                    return self.syntax_error()

                return True

            return True
        else:
            return self.syntax_error()

    def exprPrime(self):
        if self.cur_tok.lexeme in CompileEngine.operators:
            self.symbol(self.cur_tok.lexeme)
            if not self.term():
                return self.syntax_error()
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

        if not self.varName():
            return self.syntax_error()

        if self.symbol("["):
            if not self.expr():
                return self.syntax_error()

            if not self.symbol("]"):
                return self.syntax_error()

        if not self.symbol("="):
            return self.syntax_error()
        if not self.expr():
            return self.syntax_error()
        if not self.symbol(";"):
            return self.syntax_error()


        return True

    def ifStmt(self):
        """" ifStatement: 'if' '(' expression ')' '{' statements '}' """

        if not self.symbol("("):
            return self.syntax_error()
        if not self.expr():
            return self.syntax_error()
        if not self.symbol(")"):
            return self.syntax_error()
        if not self.symbol("{"):
            return self.syntax_error()

        self.statementList()

        if not self.symbol("}"):
            return self.syntax_error()

        if self.keyword("else"):
            if not self.symbol("{"):
                return self.syntax_error()

            self.statementList()

            if not self.symbol("}"):
                return self.syntax_error()

        return True


    def whileStmt(self):
        """ whileStatement: 'while' '(' expression ')' '{' statements '}' """

        if not self.symbol("("):
            return self.syntax_error()

        if not self.expr():
            return self.syntax_error()

        if not self.symbol(")"):
            return self.syntax_error()

        if not self.symbol("{"):
            return self.syntax_error()

        self.statementList()

        if not self.symbol("}"):
            return self.syntax_error()

        return True

    def doStmt(self):
        """ doStatement : 'do' subroutineCall ';' """
        lex0 = self.cur_tok.lexeme
        self.next_token()

        lex1 = self.cur_tok.lexeme
        self.next_token()
        if not self.subroutineCall(lex1):
            return self.syntax_error()

        if not self.symbol(';'):
            return self.syntax_error()
        
        return True

    def retStmt(self):
        """ returnStatement: 'return' expression? ';' """

        if not self.cur_tok.lexeme == ";":
            self.expr()

        if not self.symbol(";"):
            return self.syntax_error()

        return True

    def varNameList(self):
        if self.symbol(","):
            if not self.varName():
                return self.syntax_error()
            self.varNameList()
            return True
        return False


    def varDecList(self):
        if self.keyword("var"):
            if not self.type():
                return self.syntax_error()
            if not self.varName():
                return self.syntax_error()
            self.varNameList()
            if not self.symbol(";"):
                return self.syntax_error()

            self.varDecList()
            return True
        return  False


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


        

    def subroutineBody(self):
        """ subroutineBody : '{' varDec* statements '}' """
        if not self.symbol("{"):
            return self.syntax_error()

        self.varDecList()
        self.statementList()

        if not self.symbol("}"):
            return self.syntax_error()
        return True



    def varNames(self):
        if self.varName():
            if self.symbol(","):
                self.varNames()
            return True
        return False

    def classVarDec(self):
        """ classVarDec : ('static' | 'field') type varName (',' varName)* ';' """

        if self.keyword("static") or self.keyword("field"):
            if not self.type():
                return self.syntax_error()

            if not self.varNames():
                return self.syntax_error()

            if not self.symbol(";"):
                return self.syntax_error()

            self.classVarDec()

            return True

        return False

    def subroutineDec(self):
        """ subroutineDec : ('constructor' | 'function' | 'method') ('void' | type) subroutineName '(' parameterList ')' """

        if self.keyword("constructor") or \
            self.keyword("function") or \
                self.keyword("method") :

            if not self.returnType():
                return self.syntax_error()

            if not self.subroutineName():
                return self.syntax_error()

            if not self.symbol('('):
                return self.syntax_error()

            self.paramList()

            if not self.symbol(')'):
                return self.syntax_error()

            if not self.subroutineBody():
                return self.syntax_error()
            
            self.subroutineDec()

            return True

        return False


    def compileClass(self):
        """ class: 'class' className '{' classVarDec* subroutineDec* '}' """

        # Match the rule 'class'
        if not self.keyword("class"):
            return self.syntax_error()

        if not self.className():
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
        return self.compileClass()


if __name__ == "__main__":
    """ Compiler driver """

    jack_files = []
    for a in sys.argv:
        #if a is a folder
        if path.isdir(a):
            for file_name in os.listdir(a):
                if file_name.endswith("jack"):
                    jack_files.append(os.path.join(a,file_name))


        # add all the jack files in the folder
        if a.endswith("jack"):
            jack_files.append(a)

    for jack_file in jack_files:
        vm_file = jack_file.replace("jack", "vm")
        f = open(vm_file, "w")
        tokenizer = JackTokenizer(jack_file)
        analyzer = CompileEngine(tokenizer)

        orig_stdout = sys.stdout
        #sys.stdout = f
        analyzer.parse()
        sys.stdout = orig_stdout
