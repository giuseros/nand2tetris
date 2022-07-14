`timescale 1ns/1ns

module CPU_tb;

// Input signals(wire)
reg [15:0] instruction;

// OUtput signals(regs)

reg clk, reset;
integer j;


// Test for D = D-M
CPU dut(.instruction(instruction), 
        .inM(16'b0000000000000001),
		  .clk(clk), .reset(0),
		  .D(regD),
		  .A(regA)
		  );


always
#100 clk = ~clk;

initial begin
	clk = 0;
	#0; instruction=16'b1111010011010000;
	#500; instruction=16'b0000000000000001;
	#200; instruction=16'b1111010011010000;
	#400; instruction=16'b0000000000000001;
end


endmodule