import sys
import enum
import os
import os.path
from enum import Enum
from os import path

# State of the lexer
class LexerState(Enum):
    normal = 1
    could_comment = 2
    multiline = 3
    comment = 4
    could_end_multiline = 5
    word_detection = 6
    skip_one = 7
    string = 8


# Type of the token read
class TokenType(Enum):
    symbol = 1
    keyword = 2
    str_const = 3
    int_const = 4
    identifier = 5


class Token:
    def __init__(self, lexeme, type, line=1):
        self.lexeme = lexeme
        self.type = type
        self.line = line

    def __repr__(self):
        return f"[{self.line}]({self.lexeme}, {self.type})"


def RepresentsInt(s):
    try:
        int(s)
        return True
    except ValueError:
        return False


class JackTokenizer:
    keywords = [
        "class",
        "constructor",
        "function",
        "method",
        "field",
        "static",
        "var",
        "int",
        "char",
        "boolean",
        "void",
        "true",
        "false",
        "null",
        "this",
        "let",
        "do",
        "if",
        "else",
        "while",
        "return",
    ]

    symbols = [
        "{",
        "}",
        "(",
        ")",
        "[",
        "]",
        ".",
        ",",
        ";",
        "+",
        "-",
        "*",
        "/",
        "&",
        "|",
        "<",
        ">",
        "=",
        "-",
        "~",
    ]
    spaces = ["\n", " ", "\t"]

    def __init__(self, filename):
        self.state = LexerState.normal
        self.current_word = ""
        self.current_line_no = 1
        self.last_c = ""
        self.handle = open(filename)

    def Identifier(self, lexeme):
        return Token(lexeme, TokenType.identifier, self.current_line_no)

    def Keyword(self, lexeme):
        return Token(lexeme, TokenType.keyword, self.current_line_no)

    def Symbol(self, lexeme):
        return Token(lexeme, TokenType.symbol, self.current_line_no)

    def IntConst(self, lexeme):
        return Token(lexeme, TokenType.int_const, self.current_line_no)

    def StringConst(self, lexeme):
        return Token(lexeme, TokenType.str_const, self.current_line_no)

    def next_token(self):
        while True:

            if self.state == LexerState.skip_one:
                self.state = LexerState.normal
                c = self.last_c
            else:
                c = self.handle.read(1)
                if not c:
                    return None

            # Comment detection
            if self.state == LexerState.normal and c == "/":
                self.state = LexerState.could_comment
                continue

            if self.state == LexerState.could_comment and c == "*":
                self.state = LexerState.multiline
                continue

            if self.state == LexerState.could_comment and c == "/":
                self.state = LexerState.comment
                continue

            if self.state == LexerState.comment and c == "\n":
                self.current_line_no += 1
                self.state = LexerState.normal
                continue

            if self.state == LexerState.multiline and c == "*":
                self.state = LexerState.could_end_multiline
                continue

            if self.state == LexerState.could_end_multiline and c == "/":
                self.state = LexerState.normal
                continue

            if self.state == LexerState.could_end_multiline and c != "/":
                self.state = LexerState.multiline
                continue

            if self.state == LexerState.could_comment and c != "/":
                self.state = LexerState.skip_one
                self.last_c = c
                return self.Symbol("/")

            if self.state == LexerState.multiline and c == "\n":
                self.current_line_no += 1

            if self.state in [LexerState.comment, LexerState.multiline]:
                continue

            # String detection
            if self.state == LexerState.normal and c == '"':
                self.state = LexerState.string
                continue

            if self.state == LexerState.string and c == '"':
                self.state = LexerState.normal
                tok = self.StringConst(self.current_word)
                self.current_word = ""
                return tok

            if self.state == LexerState.string:
                self.current_word += c
                continue

            # If not a string, just ignore spaces
            if self.state == LexerState.normal and c in JackTokenizer.spaces:
                if c == "\n":
                    self.current_line_no += 1
                continue

            # Word detection
            if self.state == LexerState.normal and c in JackTokenizer.symbols:
                return self.Symbol(c)

            if self.state == LexerState.word_detection and c in (
                JackTokenizer.spaces + JackTokenizer.symbols
            ):
                if self.current_word in JackTokenizer.keywords:
                    tok = self.Keyword(self.current_word)
                elif RepresentsInt(self.current_word):
                    tok = self.IntConst(self.current_word)
                else:
                    tok = self.Identifier(self.current_word)

                self.state = LexerState.normal
                self.current_word = ""

                if c in JackTokenizer.symbols:
                    self.last_c = c
                    self.state = LexerState.skip_one

                if c == "\n":
                    self.current_line_no += 1

                return tok

            self.state = LexerState.word_detection
            self.current_word += c


if __name__ == "__main__":
    jack_src = sys.argv[1]
    lexer = JackTokenizer(jack_src)
    tok = lexer.next_token()

    while tok:
        print(tok)
        tok = lexer.next_token()
