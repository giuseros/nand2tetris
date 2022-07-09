module keyboard(
input wire clk, 
input wire ps2_clk,
input wire ps2_data, 
output reg[7:0] out);

reg [1:0] sync_ffs;
wire ps2_clk_int;
wire ps2_data_int;

reg ps2_clk_old;
reg [10:0] ps2_word;
reg [7:0] counter;

reg F0_detected;

initial begin
	counter<=0;
end

// Synchronize clock and data
always @(posedge clk) begin
	sync_ffs[0] <= ps2_clk;
	sync_ffs[1] <= ps2_data;
end

// debounce ps2 clk
debouncer debouncer1(.clk(clk), .in(sync_ffs[0]), .result(ps2_clk_int));

// debounce data clk
debouncer debouncer2(.clk(clk), .in(sync_ffs[1]), .result(ps2_data_int));

 
always @(posedge clk) begin
if (ps2_clk_int == 1'b0 && ps2_clk_old == 1'b1) begin
	 counter <= counter+1;
	 ps2_word <= {ps2_data_int, ps2_word[10:1]};
end

if (counter == 11) begin
    counter <= 0;
	 if (ps2_word[8:1] == 8'hF0) begin
		out<= 0;
		F0_detected <= 1;
	 end else if (F0_detected) begin
	 	F0_detected <= 0;
	 end else if (ps2_word[8:1] != 8'hE0) begin
		out <= ps2_word[8:1];
	 end
end

ps2_clk_old <= ps2_clk_int;

end     

endmodule
