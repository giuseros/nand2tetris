module arbitrator(
    // Input memory data (to write)
    input   wire    [14:0]  address_in,
	 input  wire    [15:0] data_in,
	 input  wire    write_in,
	 
	 // Input memory data (to read)
	 input wire [15:0] data_from_keyboard,
	 input wire [15:0] data_from_ram,	
	 input wire [15:0] data_from_video,
    
	 // Route to screen
	 output   wire    [14:0]  address_screen,
	 output   wire    [15:0] data_screen,
    output   wire    write_screen,
	 
	 // Route to ram
	 output   wire    [14:0]  address_ram,
	 output   wire    [15:0] data_ram,
    output   wire    write_ram,
	 
	 // Data read
	 output wire [15:0] data_out
);
wire [15:0] tmp;

assign address_ram = address_in < 16384 ? address_in : 15'h0;
assign data_ram = address_in < 16384 ? data_in : 16'h0;
assign write_ram = address_in < 16384 ? write_in : 1'h0;

assign address_screen = address_in >= 16384 && address_in < 24576? address_in-16384 : 15'h0;
assign data_screen = address_in >= 16384 && address_in < 24576 ? data_in : 16'h0;
assign write_screen = address_in >= 16384 && address_in < 24576 ? write_in : 1'h0;

assign tmp = address_in < 16384 ? data_from_ram : data_from_video;
assign data_out = address_in == 24576 ? data_from_keyboard : tmp;

endmodule
 