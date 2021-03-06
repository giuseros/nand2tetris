module single_port_ram #(
    parameter DATA = 16,
    parameter ADDR = 15
) (
    // Port A
    input   wire                a_clk,
    input   wire                a_wr,
    input   wire    [ADDR-1:0]  a_addr,
    input   wire    [DATA-1:0]  a_din,
    output  reg     [DATA-1:0]  a_dout
);

// Shared memory
reg [DATA-1:0] mem [(2**ADDR)-1:0];


// Use this only for simulation (it will slow down compilation)
integer i;
initial begin
	for (i=0;i<(2**ADDR)-1;i=i+1)begin
		mem[i] = 0;
	end
end

 
// Port A
always @(posedge a_clk) begin
    a_dout      <= mem[a_addr];
    if(a_wr) begin
        a_dout      <= a_din;
        mem[a_addr] <= a_din;
    end
end
 
endmodule