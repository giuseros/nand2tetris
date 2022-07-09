module arbitrator #(
    parameter DATA = 16,
    parameter ADDR = 15
) (
    // Input memory data (to write)
    input   wire    [ADDR-1:0]  address_in,
	 input  wire    [DATA-1:0] data_in,
	 input  wire    write_in,
	 
	 // Input memory data (to read)
	 input wire [DATA-1:0] data_from_keyboard,
	 input wire [DATA-1:0] data_from_ram,	
    
	 // Route to screen
	 output   wire    [ADDR-1:0]  address_screen,
	 output   wire    [DATA-1:0] data_screen,
    output   wire    write_screen,
	 
	 // Route to ram
	 output   wire    [ADDR-1:0]  address_ram,
	 output   wire    [DATA-1:0] data_ram,
    output   wire    write_ram,
	 
	 // Data read
	 output wire [DATA-1:0] data_out
);

assign address_ram = address_in < 16384 ? address_in : 0;
assign data_ram = address_in < 16384 ? data_in : 0;
assign write_ram = address_in < 16384 ? write_in : 0;

assign address_screen = address_in >= 16384 && address_in < 24576? address_in-16384 : 0;
assign data_screen = address_in >= 16384 && address_in < 24576 ? data_in : 0;
assign write_screen = address_in >= 16384 && address_in < 24576 ? write_in : 0;

assign data_out = address_in == 24576 ? data_from_keyboard : data_from_ram;

endmodule
 