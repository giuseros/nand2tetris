`timescale 1ns/1ns

module StaticTest;
reg clk, reset;

wire signed [15:0] regD;
wire [15:0] regA;
wire writeM;
wire [15:0] data_in, data_out;
wire [14:0] addressM;

wire [15:0] instruction;
wire [14:0] addressI;
wire loadPC, stall;

localparam PRG = "C:/Users/g00621769/repos/nand2tetris/Verilog/nand2tetris/src/test/StaticTest.mif";
localparam IL = 17;

task check;
input signed [31:0] actual;
input signed [31:0] expected;
begin

if (actual != expected) 
	$display("[ERROR AT %t]! expected: %d, actual: %d", $time, expected, actual);
else
	$display("[%t OK] expected: %d, actual: %d", $time, expected, actual);
end
endtask

single_port_rom #(.PRG(PRG), .IL(IL)) rom(.a_dout(instruction), 
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

always
#1 clk = ~clk;

initial begin

clk = 1'b0;

cpu_ram.mem[0] = 256;



#360
//|RAM[256]|
//|   1110 |


check (cpu_ram.mem[256], 1110);
end




endmodule

