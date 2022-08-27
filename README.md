# nand2tetris in Verilog
This repo contains a fully-fledged Verilog implementation of the [nand2tetris project](https://www.nand2tetris.org/). 

It originally contained the code I wrote to pass the course, but I am now using it to explore hardware developments concepts using nand2tetris as an experimentation platform. 

Some of the software components I wrote are still very relevant though: in particular,  the assembler, the compiler, the VM and the OS are needed to compile and run programs on the board. They have been refactored and fixed so that now should be less buggy.

## What's been implemented in Verilog
I tried to be as close as possible to the original design. So I implemented:
- The core CPU, with ALU, FetchUnit and Decoder
- Memory (with a memory arbitrator to map the VGA memory)
- Video controller
- PS2 keyboard controller


## Boards 
For now I only tested the end-to-end flow on the following board:
- [DE10-Lite](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=1021)

## My Stackoverflow posts
I have had the help of different StackOverflowers to be able to complete this project. These are the posts I wrote to get help:
- [How to implement nand2tetris processor on a real FPGA](https://stackoverflow.com/questions/66627417/how-to-implement-nand2tetris-processor-on-a-real-fpga)
- [Verilog/SystemVerilog: passing a slice of an unpacked array to a module](https://stackoverflow.com/questions/72021521/verilog-systemverilog-passing-a-slice-of-an-unpacked-array-to-a-module)
- [Scan codes from PS/2 keyboard misbehaviors](https://electronics.stackexchange.com/questions/625609/scan-codes-from-ps-2-keyboard-misbehaviors/626276#626276)

I am citing these because I think they make an interesting reading for whomever wants to try to do the same
