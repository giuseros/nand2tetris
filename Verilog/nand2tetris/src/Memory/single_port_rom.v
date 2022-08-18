module single_port_rom #(
	 parameter PRG = ""
) (
    // Port A
    input   wire                a_clk,
	 input   wire jmp,
	 input 	wire stall,
    input   wire    [14:0]  a_addr,
    output  wire     [15:0]  a_dout
);

wire [14:0] torom;
wire [15:0] torom16;
wire stalling;
reg [14:0] pc, last_pc;
reg stop_stall;

// Shared memory (we use altera syntetizable memory)
onchip_rom  #(.PRG(PRG)) ROM (.address(torom16), .clock(a_clk), .q(a_dout));

initial begin
	pc = 0;
	stop_stall=0;
end

// Sequential logic to handle the program counter
always @(posedge a_clk) begin
	 last_pc     <= pc;
	 if (jmp) begin
		pc <= a_addr + 1;
	 end else if (~stall | (stall & stop_stall) ) begin
		stop_stall <= 0;
		pc <= pc+1;
	 end else if (~stop_stall) begin
		stop_stall <= 1;
	 end
end

// Combinatorial logic to handl the address to send to the ROM
assign stallig = stall & (~stop_stall);
assign torom = (stallig? last_pc : (jmp ? a_addr : pc));
assign torom16 = {1'b0, torom};
 
endmodule