`timescale 1ns/1ns

module BasicTest;
reg clk, reset;

wire signed [15:0] regD;
wire [15:0] regA;
wire writeM;
wire [15:0] data_in, data_out;
wire [14:0] addressM;

wire [15:0] instruction;
wire [14:0] addressI;
wire loadPC, stall;

localparam PRG = "C:/Users/g00621769/repos/nand2tetris/Verilog/nand2tetris/src/test/BasicTest.mif";
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

reg signed [15:0] regDExpected[0:18];
integer i,j;

always
#1 clk = ~clk;

initial begin

clk = 1'b0;

//i = 0;
//j = 0;

cpu_ram.mem[0] = 256;
cpu_ram.mem[1] = 300;
cpu_ram.mem[2] = 400;
cpu_ram.mem[3] = 3000;
cpu_ram.mem[4] = 3010;



#664
//|RAM[256]|RAM[300]|RAM[401]|RAM[402]|RAM[3006|RAM[3012|RAM[3015|RAM[11] |
//|    472 |     10 |     21 |     22 |     36 |     42 |     45 |    510 |


check (cpu_ram.mem[256], 472);
check (cpu_ram.mem[300], 10);
check (cpu_ram.mem[401], 21);
check (cpu_ram.mem[402], 22);
check (cpu_ram.mem[3006], 36);
check (cpu_ram.mem[3012], 42);
check (cpu_ram.mem[3015], 45);
check (cpu_ram.mem[11], 510);
end



endmodule

