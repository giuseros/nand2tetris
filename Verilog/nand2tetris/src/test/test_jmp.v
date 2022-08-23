`timescale 1ps/1ps

module test_jmp(input wire dummy);
reg clk, reset;

localparam IL = 17;
localparam PRG = "/mnt/data/nand2tetris/Verilog/nand2tetris/src/test/test_jmp.mif";

wire signed [15:0] regD;
wire [15:0] regA;
wire writeM;
wire [15:0] data_in, data_out;
wire [14:0] addressM;

wire [IL-1:0] instruction;
wire [IL-2:0] addressI;
wire loadPC, stall;


single_port_ram  cpu_ram(.a_clk(clk), 
                    .a_wr(writeM), 
						  .a_addr(addressM), 
						  .a_din(data_in), 
						  .a_dout(data_out));
						 
CPU #(.IL(IL), .PRG(PRG)) CPU(
        .clk(clk), .reset(reset), 
		  .writeM(writeM),
		  .outM(data_in),
		  .addressM(addressM),
		  .inM(data_out),
		  .D(regD),
		  .A(regA)
		  );

reg signed [15:0] regDExpected;
integer i,j;

always
#1 clk = ~clk;

initial begin

clk = 1'b0;
regDExpected = -10;

# 200
if (regD != regDExpected) 
	$display("[ERROR AT %t]! expected: %d, actual: %d", 0, regDExpected, regD);
else
	$display("[%t OK] expected: %d, actual: %d", 0, regDExpected, regD);

end



endmodule

