// push constant 0
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop local 0
// deal with the segment
@LCL
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
(LOOP_START)
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
// push local 0
@0
D=A
@LCL
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
// pop local 0
// deal with the segment
@LCL
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
@LOOP_START
D; JNE
// push local 0
@0
D=A
@LCL
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
