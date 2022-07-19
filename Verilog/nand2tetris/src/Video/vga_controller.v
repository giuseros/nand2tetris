module vga_controller(
// Input from the main module
input clk, // 50Mhz clock
input reset, 
input [15:0] data_pixel, 

// Output to the VGA
output reg [13:0] address_pixel,
output reg clk_vga,
output reg hsync, 
output reg vsync, 
output reg [3:0] R, 
output reg [3:0] G, 
output reg [3:0] B);

// Temporaries
reg [9:0] hcount, vcount;
reg [3:0] bit_count;


initial begin
  hsync      = 1;
  vsync      = 1;
  hcount     = 0;
  vcount     = 0;
  bit_count   = 0;
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
		vcount <= vcount+1;
end else 
	hcount <= hcount+1;

if  (vcount >= 490 && vcount < 492)
	vsync <= 1'b0;
else
	vsync <= 1'b1;
	
if (hcount >= 656 && hcount < 752)
	hsync <= 1'b0;
else
	hsync <= 1'b1;
	
end

// pixel filling
always @(posedge clk_vga) begin
    if(hcount >= 0 && hcount <512 && vcount >= 0 && vcount < 256) begin
	   R <= {4{data_pixel[hcount % 16]}};
		G <= {4{data_pixel[hcount % 16]}};
		B <= {4{data_pixel[hcount % 16]}};

		bit_count <= bit_count+1;
		if (bit_count == 15) begin
			address_pixel <= (address_pixel + 1) % 8192;
		end
		
    end else begin
		R<=4'b0000;
		G<=4'b0000;
		B<=4'b0000;
	end
end
    
endmodule