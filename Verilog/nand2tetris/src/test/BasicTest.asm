// push constant 10
@10
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
// push constant 21
@21
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 22
@22
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop argument 2
// deal with the segment
@ARG
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
// pop argument 1
// deal with the segment
@ARG
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
// push constant 36
@36
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop this 6
// deal with the segment
@THIS
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
// push constant 42
@42
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 45
@45
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop that 5
// deal with the segment
@THAT
D=M
@5
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
// push constant 510
@510
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop temp 6
@6
D=A
@5
D=D+A
@SP
M=M-1 // SP--
A=M+1
M=D // save the segment address
A=A-1
D=M // get the value to be popped
A=A+1
A=M // get the address from memory
M=D
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
// push that 5
@5
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
// push this 6
@6
D=A
@THIS
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
// push this 6
@6
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
//add
//************************
@SP
M=M-1 // SP--
A=M
D=M
@SP
A=M-1
M=D+M
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
// push temp 6
@6
D=A
@5
A=D+A
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
