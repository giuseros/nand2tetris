`timescale 1ns/1ns

module test_mem;
reg clk, reset;

wire signed [15:0] regD;
wire [15:0] regA;
wire writeM;
wire [15:0] data_in, data_out;
wire [14:0] addressM;

wire [15:0] instruction;
wire [14:0] addressI;
wire loadPC, stall;

localparam PRG = "C:/Users/g00621769/repos/nand2tetris/Verilog/nand2tetris/src/test/BasicLoop.mif";
localparam IL = 17;

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

reg signed [15:0] regMExpected[0:18];
reg signed [15:0] mem_signed;
reg [3:0] t[0:18];
integer i,j;

always
#1 clk = ~clk;

initial begin

clk = 1'b0;
i = 0;
j = 0;


// Results extracted with the CPU emulator
regMExpected[0] = 0;
regMExpected[1] = 0;
regMExpected[2] = 0;
regMExpected[3] = 1;
regMExpected[4] = -1;
regMExpected[5] = 100;
regMExpected[6] = -101;
regMExpected[7] = 101;
regMExpected[8] = -100;
regMExpected[9] = -99;
regMExpected[10] = 101;
regMExpected[11] = 100;
regMExpected[12] = 99;
regMExpected[13] = 199;
regMExpected[14] = 99;
regMExpected[15] = 1;
regMExpected[16] = 0;
regMExpected[17] = 100;

t[0] = 2;
t[1] = 2;
t[2] = 2;
t[3] = 2;
t[4] = 2;
t[5] = 2;
t[6] = 4;
t[7] = 4;
t[8] = 2;
t[9] = 4;
t[10] = 2;
t[11] = 4;
t[12] = 2;
t[13] = 4;
t[14] = 4;
t[15] = 4;
t[16] = 4;
t[17] = 4;
t[18] = 4;



# 4
forever begin
	mem_signed = cpu_ram.mem[100];
	if (regMExpected[i] != mem_signed) 
		$display("[ERROR AT %t]! expected: %d, actual: %d\n", $time, regMExpected[i], mem_signed);
	else
		$display("[%t OK] expected: %d, actual: %d\n", $time, regMExpected[i], mem_signed);
	
	i = i+1;	#(t[i]); 
end


end



endmodule

