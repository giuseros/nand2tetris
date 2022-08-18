module single_port_ram (
    // Port A
    input   wire                a_clk,
    input   wire                a_wr,
    input   wire    [14:0]  a_addr,
    input   wire    [15:0]  a_din,
    output  reg     [15:0]  a_dout
);

// Shared memory
reg [15:0] mem [(2**15)-1:0];


// Use this only for simulation (it will slow down compilation)
//integer i;
//initial begin
//	for (i=0;i<(2**15)-1;i=i+1)begin
//		mem[i] = 0;
//	end
//end

 
// Port A
always @(posedge a_clk) begin
    a_dout      <= mem[a_addr];
    if(a_wr) begin
        a_dout      <= a_din;
        mem[a_addr] <= a_din;
    end
end
 
endmodule