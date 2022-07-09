`timescale 1ns/1ns

module CPU_tb;

// Input signals(wire)
wire [15:0] outM;
wire writeM;

reg [15:0] RAM[0:24576];
reg [15:0] ROM[0:32767];
wire[14:0] addressM, PC;


// OUtput signals(regs)

reg clk, reset;
integer j;

always @(posedge clk) begin
if (writeM)
RAM[addressM] <= outM;
end

CPU dut(.instruction(ROM[PC]), 
        .inM(RAM[addressM]),
		  .reset(switchR),
		  .outM(outM),
		  .writeM(writeM),
		  .addressM(addressM),
		  .pc(PC),
		  .clk(clk));


always
#100 clk = ~clk;

initial begin
	clk = 0;
	reset = 0;
	$readmemb("C:/AlteraPrj/de10nano_vgaHdmi_chip/quartus/src/cpu/mem.txt", ROM);
	for(j = 0; j <= 24576; j = j+1) 
		RAM[j] = 0;
end


endmodule