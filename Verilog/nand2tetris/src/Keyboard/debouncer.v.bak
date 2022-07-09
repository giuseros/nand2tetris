module debouncer(input wire clk, input wire in, output reg result); 

reg [1:0] flipflops;
wire counter_set;
reg [8:0] counter_out;

initial begin
counter_out <= 0;
flipflops <= 0;
end

assign counter_set = flipflops[0] ^ flipflops[1];

always @(posedge clk) begin

flipflops[0] <= in;
flipflops[1] <= flipflops[0];
if (counter_set) 
	counter_out <= 0;
else if (counter_out[8] == 0)
   counter_out <= counter_out +1;
else
   result <= flipflops[1];

end
endmodule
