module dual_port_ram (
    // Port A
    input   wire            a_clk,
    input   wire            a_wr,
    input   wire    [14:0]  a_addr,
    input   wire    [15:0]  a_din,
    output  reg     [15:0]  a_dout,
     
    // Port B
    input   wire            b_clk,
    input   wire            b_wr,
    input   wire    [14:0]  b_addr,
    input   wire    [15:0]  b_din,
    output  reg     [15:0]  b_dout
);
 
// Shared memory
reg [15:0] mem [8192-1:0];

// Use this only for simulation (it will slow down compilation)
//integer i;
//initial begin
//	for (i=0;i<(2**15)-1;i=i+1)begin
//		mem[i] = 0;
//	end
//end
// 
// Port A
always @(posedge a_clk) begin
    a_dout      <= mem[a_addr];
    if(a_wr) begin
        a_dout      <= a_din;
        mem[a_addr] <= a_din;
    end
end
 
// Port B
always @(posedge b_clk) begin
    b_dout      <= mem[b_addr];
    if(b_wr) begin
        b_dout      <= b_din;
        mem[b_addr] <= b_din;
    end
end
 
endmodule