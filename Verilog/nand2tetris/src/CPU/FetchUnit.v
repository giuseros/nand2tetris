module FetchUnit #(
	 parameter IL = 16,
	 parameter PRG = ""
) (
    input   wire clk,
	 input   wire jmp,
	 input 	wire stall,
	 input   wire rst,
    input   wire [IL-2:0]  jmp_addr,
	 output  wire [IL-1:0]  instruction
);

wire [15:0] torom_ext; // The onchip rom is 64K large (i.e., 16 bit address)
wire [IL-2:0] torom;
wire stalling;
reg [IL-2:0] pc, last_pc;
reg stop_stall;

wire [IL-2:0] one  = {{IL-3{1'b0}}, 1'b1};

// Shared memory (we use altera syntetizable memory)
onchip_rom  #(.PRG(PRG), .IL(IL)) ROM(.address(torom_ext), .clock(clk), .q(instruction));

initial begin
	pc = 0;
	stop_stall=0;
end

// Sequential logic to handle the program counter
always @(posedge clk) begin
	 last_pc     <= pc;
    if (jmp) begin
		pc <= jmp_addr + one;
	 end else if (~stall | (stall & stop_stall) ) begin
		stop_stall <= 0;
		pc <= pc+one;
	 end else if (~stop_stall) begin
		stop_stall <= 1;
	 end
end

// Combinatorial logic to handl the address to send to the ROM
assign stalling = stall & (~stop_stall);
assign torom = (stalling? last_pc : (jmp ? jmp_addr : pc));
assign torom_ext = ( IL==16 ? {1'b0, torom} : torom ) ;
 
endmodule