`timescale 1ns/1ns

module CPU_tb;

reg[1000*8:0] PRG;

reg clk, reset;

wire signed [15:0] regD;
wire [15:0] regA;
wire writeM;
wire [15:0] data_in, data_out;
wire [14:0] addressM;

wire [15:0] instruction;
wire [14:0] addressI;
wire loadPC, stall;

single_port_rom #(.PRG("C:/Users/g00621769/repos/nand2tetris/Verilog/nand2tetris/src/test/test_comp.bin")) rom(.a_dout(instruction), 
                    .a_addr(addressI), 
						  .a_clk(clk),
						  .stall(stall),
						  .jmp(loadPC));
						  

single_port_ram cpu_ram(.a_clk(clk), 
                    .a_wr(writeM), 
						  .a_addr(addressM), 
						  .a_din(data_in), 
						  .a_dout(data_out));
						 
CPU dut(.instruction(instruction), 
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
PRG = "C:/Users/g00621769/repos/nand2tetris/Verilog/nand2tetris/src/test/test_comp.bin";

clk = 1'b0;
i = 0;
j = 0;


// Results extracted with the CPU emulator
regDExpected[0] = 0;
regDExpected[1] = 0;
regDExpected[2] = 1;
regDExpected[3] = -1;
regDExpected[4] = 100;
regDExpected[5] = -101;
regDExpected[6] = -101;
regDExpected[7] = 101;
regDExpected[8] = -100;
regDExpected[9] = -99;
regDExpected[10] = 101;
regDExpected[11] = 100;
regDExpected[12] = 99;
regDExpected[13] = 199;
regDExpected[14] = 99;
regDExpected[15] = 1;
regDExpected[16] = 0;
regDExpected[17] = 100;


# 4
forever begin
	
	if (regDExpected[i] != regD) 
		$display("[ERROR AT %t]! expected: %d, actual: %d\n", $time, regDExpected[i], regD);
	else
		$display("[%t OK] expected: %d, actual: %d\n", $time, regDExpected[i], regD);
	
	i = i+1;	#2; 
end


end



endmodule

