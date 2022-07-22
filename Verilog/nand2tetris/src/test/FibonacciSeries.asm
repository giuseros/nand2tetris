// push argument 1
@1
D=A
@ARG
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
// pop pointer 1
@SP
M=M-1 // SP--
A=M
D=M
@THAT
M=D
// push constant 0
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop that 0
// deal with the segment
@THAT
D=M
@0
D=D+A // in D there is the address where we should write
// deal with the SP
@SP
M=M-1 // SP--
A=M+1
M=D // save the segment address
A=A-1
D=M // get the value to be popped
A=A+1
A=M // get the address from memory
M=D
// push constant 1
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop that 1
// deal with the segment
@THAT
D=M
@1
D=D+A // in D there is the address where we should write
// deal with the SP
@SP
M=M-1 // SP--
A=M+1
M=D // save the segment address
A=A-1
D=M // get the value to be popped
A=A+1
A=M // get the address from memory
M=D
// push argument 0
@0
D=A
@ARG
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
// push constant 2
@2
D=A
@SP
A=M
M=D
@SP
M=M+1
//************************
//sub
//************************
@SP
M=M-1 // SP--
A=M
D=M
@SP
A=M-1
M=M-D
// pop argument 0
// deal with the segment
@ARG
D=M
@0
D=D+A // in D there is the address where we should write
// deal with the SP
@SP
M=M-1 // SP--
A=M+1
M=D // save the segment address
A=A-1
D=M // get the value to be popped
A=A+1
A=M // get the address from memory
M=D
(MAIN_LOOP_START)
// push argument 0
@0
D=A
@ARG
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
//if-goto
@SP
M=M-1 // SP--
A=M
D=M
@COMPUTE_ELEMENT
D; JNE
@END_PROGRAM
0; JMP
(COMPUTE_ELEMENT)
// push that 0
@0
D=A
@THAT
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
// push that 1
@1
D=A
@THAT
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
//************************
//add
//************************
@SP
M=M-1 // SP--
A=M
D=M
@SP
A=M-1
M=D+M
// pop that 2
// deal with the segment
@THAT
D=M
@2
D=D+A // in D there is the address where we should write
// deal with the SP
@SP
M=M-1 // SP--
A=M+1
M=D // save the segment address
A=A-1
D=M // get the value to be popped
A=A+1
A=M // get the address from memory
M=D
// push pointer 1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
// push constant 1
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
//************************
//add
//************************
@SP
M=M-1 // SP--
A=M
D=M
@SP
A=M-1
M=D+M
// pop pointer 1
@SP
M=M-1 // SP--
A=M
D=M
@THAT
M=D
// push argument 0
@0
D=A
@ARG
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
// push constant 1
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
//************************
//sub
//************************
@SP
M=M-1 // SP--
A=M
D=M
@SP
A=M-1
M=M-D
// pop argument 0
// deal with the segment
@ARG
D=M
@0
D=D+A // in D there is the address where we should write
// deal with the SP
@SP
M=M-1 // SP--
A=M+1
M=D // save the segment address
A=A-1
D=M // get the value to be popped
A=A+1
A=M // get the address from memory
M=D
@MAIN_LOOP_START
0; JMP
(END_PROGRAM)
