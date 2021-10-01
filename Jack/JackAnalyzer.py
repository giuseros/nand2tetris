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
    print(f"<keyword> {tok} </keyword>")

def EmitString(tok):
    print(f"<stringConstant> {tok} </stringConstant>")

def EmitInt(tok):
    print(f"<integerConstant> {tok} </integerConstant>")

def EmitIdentifier(tok):
    print(f"<identifier> {tok} </identifier>")

def EmitSymbol(tok):
    if tok == ">":
        tok = "&gt;"
    if tok == "<":
        tok = "&lt;"
    if tok == "&":
        tok = "&amp;"

    print(f"<symbol> {tok} </symbol>")

def EmitOp(tok):
    print(f"<op> {tok} </op>")

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


class CompileEngine:

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
        EmitIdentifier(cur_tok)
        

    def is_type(self, tok, typ):
        if (tok in ["int", "char", "boolean"]):
            return TokenType.PRIMITIVE_TYPE
        elif typ == "identifier":
            return TokenType.CLASS_TYPE
        else:
            return TokenType.ERROR

    def atype(self):
        (cur_tok, token_type) = self.advance()
        is_primitive_type = cur_tok in ["int", "char", "boolean"]
        is_class = token_type == "identifier"
        if not (is_primitive_type or is_class):
            self.cur_tok -= 1
            raise ValueError("Error")
        if is_primitive_type:
            EmitKeyword(cur_tok)
        else:
            EmitIdentifier(cur_tok)

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
        self.identifier()

    def className(self):
        self.identifier()

    def subroutineName(self):
        self.identifier()

    def classVarDec(self, tok):
        print("<classVarDec>")
        EmitKeyword(tok)
        self.atype()
        self.varName()
        tok,typ = self.advance()
        while tok == ",":
            EmitSymbol(tok)
            self.varName()
            tok,typ = self.advance()
        self.cur_tok -= 1
        self.symbol(';')
        print("</classVarDec>")

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

    def paramList(self):
        print("<parameterList>")
        tok,typ = self.advance()
        # a type
        is_primitive_type = tok in ["int", "char", "boolean"]
        is_class = typ == "identifier"
        if is_primitive_type or is_class:
            EmitType(tok, typ)
            self.varName()
            tok,typ = self.advance()
            while tok == ",":
                EmitSymbol(tok)
                self.atype()
                self.varName()
                tok,typ = self.advance()
            self.cur_tok -= 1
        else:
            self.cur_tok -= 1
        print("</parameterList>")

    def varDec(self):
        self.atype()
        self.varName()
        tok,typ = self.advance()
        while tok == ",":
            EmitSymbol(tok)
            self.varName()
            tok,typ = self.advance()
        self.cur_tok -= 1
        self.symbol(";")

    def letStmt(self):
        print("<letStatement>")
        EmitKeyword("let")
        self.varName()
        tok, typ = self.advance()
        if tok == "[":
            EmitSymbol(tok)
            self.expr()
            self.symbol("]")
        else:
            self.cur_tok -= 1

        self.symbol("=")
        self.expr()
        self.symbol(";")
        print("</letStatement>")

    def ifStmt(self):
        print("<ifStatement>")
        EmitKeyword("if")
        self.symbol("(")
        self.expr()
        self.symbol(")")
        self.symbol("{")
        self.statements()
        self.symbol("}")
        tok, typ = self.advance()
        if tok == "else":
            EmitKeyword("else")
            self.symbol("{")
            self.statements()
            self.symbol("}")
        else:
            self.cur_tok -= 1
        print("</ifStatement>")


    def whileStmt(self):
        print("<whileStatement>")
        EmitKeyword("while")
        self.symbol("(")
        self.expr()
        self.symbol(")")
        self.symbol("{")
        self.statements()
        self.symbol("}")
        print("</whileStatement>")

    def doStmt(self):
        print("<doStatement>")
        EmitKeyword("do")
        self.subroutineCall()
        self.symbol(';')
        print("</doStatement>")

    def retStmt(self):
        print("<returnStatement>")
        EmitKeyword("return")
        tok, typ = self.advance()
        if tok == ";":
            EmitSymbol(";")
        else:
            self.cur_tok -= 1
            self.expr()
            self.symbol(";")
        print("</returnStatement>")

    def expr(self):
        print("<expression>")
        self.term()
        tok, typ = self.advance()
        while tok in ["+", "-", "*", "/", "&", "|", "<", ">", "="]:
            EmitSymbol(tok)
            self.term()
            tok, typ = self.advance()
        self.cur_tok -= 1
        print("</expression>")

    def term(self):
        print("<term>")
        tok, typ = self.advance()
        if typ == "int_const":
            EmitInt(tok)
        elif typ == "str_const":
            EmitString(tok)
        elif tok == "(":
            EmitSymbol(tok)
            self.expr()
            self.symbol(")")
        elif typ == "keyword":
            EmitKeyword(tok)
        elif tok in  ['-', '~']:
            EmitSymbol(tok)
            self.term()
        elif typ == "identifier":
            EmitIdentifier(tok)
            tok1, typ1 = self.advance()
            if tok1 == "(":
                EmitSymbol(tok1)
                self.exprList()
            elif tok1 == ".":
                EmitSymbol(tok1)
                self.subroutineName()
                self.symbol("(")
                self.exprList()
            elif tok1 == '[':
                EmitSymbol(tok1)
                self.expr()
                self.symbol("]")
            else:
                self.cur_tok -= 1
        print("</term>")

    def exprList(self):
        print("<expressionList>")
        tok, typ = self.advance()
        if tok == ")":
            print("</expressionList>")
            EmitSymbol(")")
        else:
            self.cur_tok -= 1
            self.expr()
            tok, typ = self.advance()
            while tok == ",":
                EmitSymbol(tok)
                self.expr()
                tok, typ = self.advance()
            self.cur_tok -= 1
            print("</expressionList>")
            self.symbol(")")

    def subroutineCall(self):
        self.identifier()

        tok1, typ1 = self.advance()

        if tok1 == "(":
            EmitSymbol("(")
            self.exprList()
        elif tok1 == ".":
            EmitSymbol(".")
            self.subroutineName()
            self.symbol("(")
            self.exprList()
        

    def statements(self):
        print("<statements>")
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
            else:
                raise ValueError("Error")
            tok,typ = self.advance()
        self.cur_tok -= 1
        print("</statements>")


    def subroutineBody(self):
        print("<subroutineBody>")
        self.symbol("{")
        tok,typ = self.advance()
        while tok == "var":
            print("<varDec>")
            EmitKeyword(tok)
            self.varDec()
            tok,typ = self.advance()
            print("</varDec>")
        self.cur_tok -= 1

        self.statements()
        self.symbol("}")
        print("</subroutineBody>")


    def subroutineDec(self):
        self.returnType()
        self.subroutineName()
        self.symbol('(')
        self.paramList()
        self.symbol(')')
        self.subroutineBody()

    def __init__(self, tokens):
        self.tokens = tokens
        self.cur_tok = 0

    def compileClass(self):
        print("<class>")
        self.keyword("class")
        self.identifier()
        self.symbol("{")

        #classVarDec*
        tok,typ = self.advance()
        while tok in ["static", "field"]:
            self.classVarDec(tok)
            tok, typ = self.advance()
        self.cur_tok-=1
        tok,typ = self.advance()

        while tok in ["constructor", "function", "method", "void"]:
            print("<subroutineDec>")
            EmitKeyword(tok)
            self.subroutineDec()
            print("</subroutineDec>")
            tok,typ = self.advance()

        self.cur_tok-=1
        self.symbol("}")
        print("</class>")


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
        xml_file = jack_file.replace("jack", "xml")

        f = open(xml_file, "w")

        tokens = JackTokenizer(jack_file)
        analyzer = CompileEngine(tokens)
        orig_stdout = sys.stdout
        sys.stdout = f
        analyzer.parse()
        sys.stdout = orig_stdout
