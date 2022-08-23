module keyboard(
input wire clk, 
input wire ps2_clk,
input wire ps2_data, 
output wire[7:0] out);

reg [1:0] sync_ffs;
wire ps2_clk_int;
wire ps2_data_int;

reg ps2_clk_old;
reg [10:0] ps2_word;
reg [7:0] counter;

reg F0_detected;
reg [7:0] out_ps2;

function [7:0] f(input reg[7:0] code);
case (code)
    8'h15 : f = 81; // Q
	 8'h1D : f = 87; // W
	 8'h24 : f = 69; // E
	 8'h2D : f = 82; // R
	 8'h2C : f = 84; // T
	 8'h35 : f = 89; // Y
	 8'h3C : f = 85; // U
	 8'h43 : f = 73; // I
	 8'h44 : f = 79; // O
	 8'h4D : f = 80; // P
	 
    8'h1C : f = 65; // A
	 8'h1B : f = 83; // S
	 8'h23 : f = 68; // D
	 8'h2B : f = 70; // F
	 8'h34 : f = 71; // G
	 8'h33 : f = 72; // H
	 8'h3B : f = 74; // J
	 8'h42 : f = 75; // K
	 8'h4B : f = 76; // L
	 
	 8'h1A : f = 90; // Z
	 8'h22 : f = 88; // X
	 8'h21 : f = 67; // C
	 8'h2A : f = 86; // V
	 8'h32 : f = 66; // B
	 8'h31 : f = 78; // N
	 8'h3A : f = 77; // M
	 
	 // Numbers on the numeric pad
	 8'h70 : f = 48; // 0
	 8'h69 : f = 49; // 1
	 8'h72 : f = 50; // 2
	 8'h7A : f = 51; // 3
	 8'h6B : f = 52; // 4
	 8'h73 : f = 53; // 5
	 8'h74 : f = 54; // 6
	 8'h6C : f = 55; // 7
	 8'h75 : f = 56; // 8
	 8'h7D : f = 57; // 9
	 
	 // Numbers on the keyboard
	 8'h45 : f = 48; // 0
	 8'h16 : f = 49; // 1
	 8'h1E : f = 50; // 2
	 8'h26 : f = 51; // 3
	 8'h25 : f = 52; // 4
	 8'h2E : f = 53; // 5
	 8'h36 : f = 54; // 6
	 8'h3D : f = 55; // 7
	 8'h3E : f = 56; // 8
	 8'h46 : f = 57; // 9
	 
	 
	 // Symbols
	 8'h29 : f = 32; // space bar
	 8'h5A : f = 128; // enter
	 8'h66 : f = 129; // backspace
	 
	 
    default     : f = code;
endcase
endfunction

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
	 counter <= counter+8'h1;
	 ps2_word <= {ps2_data_int, ps2_word[10:1]};
end

if (counter == 11) begin
    counter <= 0;
	 if (ps2_word[8:1] == 8'hF0) begin
		out_ps2<= 0;
		F0_detected <= 1;
	 end else if (F0_detected) begin
	 	F0_detected <= 0;
	 end else if (ps2_word[8:1] != 8'hE0) begin
		out_ps2 <= ps2_word[8:1];
	 end
end

ps2_clk_old <= ps2_clk_int;

end     

assign out = f(out_ps2);
endmodule
