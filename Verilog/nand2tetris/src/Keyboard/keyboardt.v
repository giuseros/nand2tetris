`timescale 1ns/1ns

module keyboard_tb;

reg clock50, ps2_clk, ps2_data;
reg data[10:0];

wire ps2_code_new;
wire [7:0] LED;
integer i;


keyboard dut(
.clock50(clock50),
.ps2_clk(ps2_clk),
.ps2_data(ps2_data),
.ps2_code_new(ps2_code_new),
.LED(LED));


always
begin
clock50 <=0; #10;
clock50 <=1; #10;
end


initial begin
	clock50 <= 0;
//   ps2_clk <= 1;
   ps2_clk <= 0;
	ps2_data <= 1;
	data[0] <=1;
	data[1] <=1;
	data[2] <=0;
	data[3] <=1;
	data[4] <=1;
	data[5] <=1;
	data[6] <=0;
	data[7] <=0;
	data[8] <=0;
	data[9] <=0;
	data[10]<=1;
	#230000
	for(i=0; i<11;i=i+1) begin
//	ps2_data <=data[i]; #1003;
	ps2_clk  <=1; #50004;
	ps2_clk <=0; #50005;
	end
	ps2_clk <= 1; 

end


endmodule