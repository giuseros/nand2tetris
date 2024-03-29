module vga_controller(
// Input from the main module
input clk, // 50Mhz clock
input reset, 
input [15:0] data_pixel, 

// Output to the VGA
output reg [14:0] address_pixel,
output reg clk_vga,
output reg hsync, 
output reg vsync, 
output reg [3:0] R, 
output reg [3:0] G, 
output reg [3:0] B);

// Temporaries
reg  [9:0]  hcount, vcount;
reg  [3:0]  bit_count;
wire [14:0] address_pixel_plus_1;

initial begin
  hsync      = 1;
  vsync      = 1;
  hcount     = 0;
  vcount     = 0;
  bit_count   = 0;
  clk_vga = 0;
  address_pixel =0;
end


// 25Mhz clock
always @(posedge clk) begin
	clk_vga <= !clk_vga;
end


// hsync/vsync generation
always @(posedge clk_vga) begin
if(hcount==799) begin
	hcount <= 0;
	if (vcount == 524) 
		vcount <= 0;
	else
		vcount <= vcount+10'h1;
end else 
	hcount <= hcount+10'h1;

if  (vcount >= 489 && vcount < 491)
	vsync <= 1'b0;
else
	vsync <= 1'b1;
	
if (hcount >= 655 && hcount < 751)
	hsync <= 1'b0;
else
	hsync <= 1'b1;
	
end


assign address_pixel_plus_1 = (address_pixel + 15'h1);

// pixel filling
always @(posedge clk_vga) begin
    if(hcount >= 0 && hcount <512 && vcount >= 0 && vcount < 256) begin
	   R <= {4{data_pixel[hcount % 16]}};
		G <= {4{data_pixel[hcount % 16]}};
		B <= {4{data_pixel[hcount % 16]}};

		bit_count <= bit_count+4'h1;
		
		// Start fetching the next data_pixel one cycle earlier
		if (bit_count == 14) begin
			address_pixel <= address_pixel_plus_1[12:0];
		end
		
    end else begin
		R<=4'b0000;
		G<=4'b0000;
		B<=4'b0000;
	end
end
    
endmodule