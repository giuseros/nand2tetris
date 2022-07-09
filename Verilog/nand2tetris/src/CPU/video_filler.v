module video_filler(
input clk,
output reg [15:0] outM, 
output reg [14:0] addressM,
output writeM);

reg [12:0] counter;

assign writeM = 1'b1;

initial begin
counter <= 0;
end

always @(posedge clk) begin
counter <= counter + 1;
end

always @(posedge clk) begin
outM <= 16'hffff;
addressM <= counter + 16384;
end

endmodule