module single_port_rom #(
    parameter DATA = 16,
    parameter ADDR = 15, 
	 parameter PRG = ""
) (
    // Port A
    input   wire                a_clk,
	 input   wire jmp,
	 input 	wire stall,
    input   wire    [ADDR-1:0]  a_addr,
    output  reg     [DATA-1:0]  a_dout
);
 
// Shared memory
reg [DATA-1:0] mem [(2**ADDR)-1:0];
reg [ADDR-1:0] addr_reg;
reg [ADDR-1:0] pc, last_pc;

initial begin
	$readmemb(PRG, mem);
	addr_reg = 0;
	pc = 0;
	a_dout = 0;
end
 
// Port A
always @(posedge a_clk) begin
	 last_pc     <= pc;
	 if (jmp) begin
		a_dout <= mem[a_addr];
		pc <= a_addr + 1;
	 end else if (stall) begin
	   a_dout <= mem[last_pc];
		pc <= last_pc +1;
	 end else begin
	   a_dout <= mem[pc];
		pc <= pc+1;
	 end
end
 
endmodule