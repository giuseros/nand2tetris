import sys
import enum
import os
import re

def log(astring):
    sys.stderr.write(astring)

class CommandType(enum.Enum):
    C_ARITHMETIC = 0
    C_PUSH = 1
    C_POP =2
    C_LABEL = 3
    C_GOTO =4
    C_IF=5
    C_FUNCTION=6
    C_RETURN=7
    C_CALL=8


def parse(vm_program):
    f = open(vm_program)
    tokens = []
    for l in f:
        t = ()
        l = l.strip()
        l = re.sub(r' *//.*', '', l)
        if l.startswith("push"):
            t = (CommandType.C_PUSH, l.split()[1], l.split()[2])
        elif l.startswith("pop"):
            t = (CommandType.C_POP, l.split()[1], l.split()[2])
        elif l in ["add", "sub", "lt", "gt", "eq", "not", "or", "and", "neg"]:
            t = (CommandType.C_ARITHMETIC, l, None)
        elif l.startswith("label"):
            t = (CommandType.C_LABEL, l.split()[1], None)
        elif l.startswith("goto"):
            t = (CommandType.C_GOTO, l.split()[1], None)
        elif l.startswith("if-goto"):
            t = (CommandType.C_IF, l.split()[1], None)
        elif l.startswith("function"):
            t = (CommandType.C_FUNCTION, l.split()[1], l.split()[2])
        elif l.startswith("return"):
            t = (CommandType.C_RETURN, None, None)
        elif l.startswith("call"):
            t = (CommandType.C_CALL, l.split()[1], l.split()[2])

        if len(t)>0:
            tokens.append(t)
        
    return tokens

def segment_pointer(seg):
    if seg == "local":
        return "LCL"
    if seg == "argument":
        return "ARG"
    if seg == "this":
        return "THIS"
    if seg == "that":
        return "THAT"

def comment(txt):
    print("//"+txt)
            
def increment_sp():
    print("@SP")
    print("M=M+1")

def decrement_sp():
    print("@SP")
    print("M=M-1 // SP--")

def stack_push():
    print("@SP")
    print("A=M")
    print("M=D")
    increment_sp()

def stack_pop_save():
    # We need to pop_save when we do pointer math to access 
    # the segmenet (e.g., LCL[x])
    decrement_sp()
    print("A=M+1")
    print("M=D // save the segment address")
    print("A=A-1")
    print("D=M // get the value to be popped")
    print("A=A+1")
    print("A=M // get the address from memory")
    print("M=D")

def stack_pop():
    # We can use stack_pop when we don't need to do any pointer 
    # math in order to get the data (e.g., @Foo; D=M)
    decrement_sp()
    print("A=M")
    print("D=M")

def write_push(segment, val, workspace):
    print("// push " + segment + " " + val)


    if segment == "constant":
        print("@"+val)
        print("D=A")
        stack_push()
    elif segment in ["local", "argument", "this", "that"]:
        print("@"+val)
        print("D=A")
        print("@" + segment_pointer(segment))
        print("A=D+M")
        print("D=M")
        stack_push()
    elif segment == "static":
        print("@" + workspace +"."+val)
        print("D=M")
        stack_push()
    elif segment == "temp":
        print("@"+val)
        print("D=A")
        print("@5")
        print("A=D+A")
        print("D=M")
        stack_push()
    elif segment == "pointer":
        if (val == "0"):
            print("@THIS")
        else:
            print("@THAT")
        print("D=M")
        stack_push()
    
def write_pop(segment, val, workspace):
    print("// pop " + segment + " " + val)

    if segment in ["local", "argument", "this", "that"]:

        print("// deal with the segment")
        print("@"+segment_pointer(segment))
        print("D=M")
        print("@" + val)
        print("D=D+A // in D there is the address where we should write")

        print("// deal with the SP")
        stack_pop_save()
    elif segment == "static":
        stack_pop()
        print("@"+workspace+"."+val)
        print("M=D")
    elif segment == "temp":
        print("@"+val)
        print("D=A")
        print("@5")
        print("D=D+A")
        stack_pop_save()
    elif segment == "pointer":
        stack_pop()
        if (val == "0"):
            print("@THIS")
        else:
            print("@THAT")
        print("M=D")

class Label:
    cnt = 0

def gen_label():
    Label.cnt = Label.cnt +1
    return "label_"+str(Label.cnt)

def write_arith(cmd):
    print("//************************")
    print("//"+cmd)
    print("//************************")
    # Unary 
    if cmd == "not":
        print("@SP")
        print("A=M-1")
        print("M=!M")
        return
    if cmd  == "neg":
        print("@SP")
        print("A=M-1")
        print("M=-M")
        return 

    # Binary
    # pop into D
    stack_pop()
    print("@SP")
    print("A=M-1")
    if cmd=="add":
        print("M=D+M")
    elif cmd=="sub":
        print("M=M-D")
    elif cmd == "and":
        print("M=D&M")
    elif cmd == "or":
        print("M=D|M")
    else:
        jmp = gen_label()
        end = gen_label()
        print("D=M-D")
        print("@"+jmp)
        print("D;J"+ cmd.upper())

        # *SP = 0 
        print("@SP")
        print("A=M-1")
        print("M=0")

        print("@" + end)
        print("0; JMP")
        print("(" + jmp + ")")
        # *SP = 0
        print("@SP")
        print("A=M-1")
        print("M=-1")
        print("(" + end + ")")

def write_label(label):
    print("(" + label + ")")

def write_goto(label):
    print("@"+label)
    print("0; JMP")

def write_if_goto(label):
    print("//if-goto")
    stack_pop()
    print("@"+label)
    print("D; JNE")


def write_function(label, nlocals):
    print("//function declaration")
    print("(" + label + ")")
    for i in range(0, int(nlocals)):
        print("@0")
        print("D=A")
        stack_push()

def index_backward(var, index):
    print("@"+str(index))
    print("D=A")
    print("@"+var)
    print("A=M-D")
    print("D=M")

def assign_backward(orig, index, dest):
    index_backward(orig, index)
    print("@"+dest)
    print("M=D")


def write_return():
    endframe = "R13"
    retaddr = "R14"
    print("//Return")
    print("//Save LCL")
    print("@LCL")
    print("D=M")
    print("@" + endframe)
    print("M=D")

    print("// Save retAddr")
    assign_backward("LCL", 5, retaddr)

    print("// *arg=pop()")
    stack_pop()
    print("@ARG")
    print("A=M")
    print("M=D")

    print("// sp = arg+1")
    print("@ARG")
    print("D=M")
    print("@SP")
    print("M=D+1")

    print("//restore that, this, arg, lcl")
    assign_backward(endframe, 1, "THAT")
    assign_backward(endframe, 2, "THIS")
    assign_backward(endframe, 3, "ARG")
    assign_backward(endframe, 4, "LCL")

    print("@"+retaddr)
    print("A=M")
    print("0;JMP")

def push_segment(seg_name):
    print("@"+seg_name)
    print("D=M")
    stack_push()


def write_call(function_name, nargs):
    comment("call")
    return_address = gen_label()
    print("@" + return_address)
    print("D=A")
    stack_push()
    push_segment("LCL")
    push_segment("ARG")
    push_segment("THIS")
    push_segment("THAT")
    print("@"+nargs)
    print("D=A")
    print("@5")
    print("D=D+A")
    print("@SP")
    print("D=M-D")
    print("@ARG")
    print("M=D")
    print("@SP")
    print("A=M")
    print("D=A")
    print("@LCL")
    print("M=D")
    print("@"+function_name)
    print("0; JMP")
    print("("+return_address+")")

def write_init():
    print("@256")
    print("D=A")
    print("@SP")
    print("M=D")
    write_call("Sys.init", "0")


def write_hack(tokens, workspace, enable_init):
    if enable_init:
        write_init()
    for t in tokens:
        if t[0] == CommandType.C_PUSH:
            write_push(t[1], t[2], workspace)
        elif t[0] == CommandType.C_POP:
            write_pop(t[1], t[2], workspace)
        elif t[0] == CommandType.C_ARITHMETIC:
            write_arith(t[1])
        elif t[0] == CommandType.C_LABEL:
            write_label(t[1])
        elif t[0] == CommandType.C_GOTO:
            write_goto(t[1])
        elif t[0] == CommandType.C_IF:
            write_if_goto(t[1])
        elif t[0] == CommandType.C_FUNCTION:
            write_function(t[1], t[2])
        elif t[0] == CommandType.C_RETURN:
            write_return()
        elif t[0] == CommandType.C_CALL:
            write_call(t[1], t[2])



if __name__=="__main__":
    source = sys.argv[1]
    orig_stdout = sys.stdout

    sources = []
    if os.path.isdir(source):
        enable_init = True
        program_name = os.path.split(source)[-1]
        program_path = os.path.join(source , program_name + ".asm")

        for f in os.listdir(source):
            if f.endswith(".vm"):
                sources.append(os.path.join(source,f))
    else:
        enable_init = False
        program_name = os.path.splitext(os.path.split(source)[-1])[0]
        program_path = os.path.splitext(source)[0] + ".asm"
        sources.append(source)


    with open(program_path, "w") as f:
        for s in sources:
            tokens = parse(s)
            static_workspace = os.path.splitext(os.path.split(s)[-1])[0]
            sys.stdout = f
            write_hack(tokens, static_workspace, enable_init)
            sys.stdout = orig_stdout
