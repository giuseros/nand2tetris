// push constant 3030
@3030
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop pointer 0
@SP
M=M-1 // SP--
A=M
D=M
@THIS
M=D
// push constant 3040
@3040
D=A
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
// push constant 32
@32
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop this 2
// deal with the segment
@THIS
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
// push constant 46
@46
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop that 6
// deal with the segment
@THAT
D=M
@6
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
// push pointer 0
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
// push pointer 1
@THAT
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
// push this 2
@2
D=A
@THIS
A=D+M
D=M
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
// push that 6
@6
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
