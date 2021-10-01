// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

// Put your code here.



(LOOP)

@KBD
D=M

@FILLB
D; JNE

//(FILLW)
@val
M=0
@FILL
0; JMP

(FILLB)
@val
M=-1
@FILL
0; JMP


@LOOP
0; JMP


(FILL)

@8192
D=A

@i
M=D // Size in words of the screen

@SCREEN
D=A

@ptr
M=D

(LOOP2)

@val
D=M

@ptr
A=M
M=D

@ptr
M=M+1

@i
M=M-1
D=M

@LOOP2
D;JGT

@LOOP
0; JMP
