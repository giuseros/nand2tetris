`timescale 1ps/1ps

module test_jmp(input wire dummy);
reg clk, reset;

wire signed [15:0] regD;
wire [15:0] regA;
wire writeM;
wire [15:0] data_in, data_out;
wire [14:0] addressM;

wire [15:0] instruction;
wire [14:0] addressI;
wire loadPC, stall;

single_port_rom #(.PRG("/mnt/data/nand2tetris/Verilog/nand2tetris/src/test/test_jmp.mif")) rom(.a_dout(instruction), 
                    .a_addr(addressI), 
						  .a_clk(clk),
						  .stall(stall),
						  .jmp(loadPC));
						  

single_port_ram cpu_ram(.a_clk(clk), 
                    .a_wr(writeM), 
						  .a_addr(addressM), 
						  .a_din(data_in), 
						  .a_dout(data_out));
						 
CPU CPU(.instruction(instruction), 
        .clk(clk), .reset(0), .stall(stall),
		  .writeM(writeM),
		  .outM(data_in),
		  .loadPC(loadPC),
		  .addressI(addressI),
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

