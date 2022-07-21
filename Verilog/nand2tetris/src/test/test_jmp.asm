@main
0; JMP

(func1)
@100
D=D-A
@a
D; JEQ
@b
D; JGT
@c
D; JLT

(func2)
@100
D=D-A
@d
D; JGE
@60
D=D+A
@e
D; JGE

(func3)
@100
D=D-A
@f
D; JLE
@200
D=D-A
@g
D; JLE

(func4)
@100
D=D-A
@h
D; JNE


(main)
@100
D=A
@func1
0; JMP

// Test jeq, jgt, jlt
(a)
@101
D=A
@func1
0; JMP
(b)
@99
D=A
@func1
0; JMP 

// Test jge
(c)
@100
D=A
@func2
0; JMP
(d)
@50
D=A
@func2
0; JMP

// Test jle
(e)
@100
D=A
@func3
0; JMP
(f)
@199
D=A
@func3
0; JMP

// Test jne
(g)
@90
D=A
@func4
0; JMP


(h)
@h
0; JMP
