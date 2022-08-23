module ALU(
input signed [15:0]x, y,
input zx, nx, zy, ny, f, no,
output signed [15:0]out, 
output zr, ng);

wire [15:0] x0, x1;
wire [15:0] y0, y1;
wire [15:0] out0;
             
 
assign x0 = ((zx == 1)? 16'h0 : x);
assign x1 = (nx == 1)? ~x0 : x0;
assign y0 = (zy == 1)? 16'h0 : y;
assign y1 = (ny == 1)? ~y0 : y0;
assign out0 = (f ? x1+y1 : x1&y1);
assign out = (no==1)? ~out0:out0;
assign zr = (out==0);
assign ng = (out<0);
  
endmodule