
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module nand2tetris(

	//////////// CLOCK //////////
	input 		          		ADC_CLK_10,
	input 		          		MAX10_CLK1_50,
	input 		          		MAX10_CLK2_50,

	//////////// SEG7 //////////
	output		     [7:0]		HEX0,
	output		     [7:0]		HEX1,
	output		     [7:0]		HEX2,
	output		     [7:0]		HEX3,
	output		     [7:0]		HEX4,
	output		     [7:0]		HEX5,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// VGA //////////
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS,

	//////////// GPIO, GPIO connect to GPIO Default //////////
	inout 		    [35:0]		nand2tetrisGPIO
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

// Renaming 
wire rst, clk;
wire [11:0] data_pixel;
wire [7:0] key_pressed;

assign rst = KEY[0];
assign data_pixel = 12'hFFF;
assign clk = MAX10_CLK1_50;

assign ps2_clk = nand2tetrisGPIO[0];
assign ps2_data = nand2tetrisGPIO[1];

// CPU memory output signals 
wire[15:0] outM;
wire[14:0] addressM;
wire writeM;

// Connections arbritator-ram
wire [14:0] address_ram;
wire [15:0] data_ram;
wire we_ram;

// Connections arbritator-screen
wire [14:0] address_screen, address_vga;
wire [15:0] data_screen, data_vga;
wire we_screen;
wire clk_vga;

wire [15:0] inM;
wire [7:0] data_keyboard;
wire [15:0] data_ram_out;

wire [15:0] regA;
wire [15:0] regD;
wire [15:0] regToDisplay;

assign regToDisplay = (SW == 10'h0 ? 0 : (SW == 10'h1 ? regD : regA));


arbitrator arbitrator(.address_in(addressM), 
                      .write_in(writeM),
							 .data_in(outM), 
							 
							 .write_screen(we_screen),
							 .data_screen(data_screen),
							 .address_screen(address_screen),
							 
							 .write_ram(we_ram),
							 .data_ram(data_ram),
							 .address_ram(address_ram),
							 
							 .data_from_keyboard({8'h00, key_pressed}),
							 .data_from_ram(data_ram_out),
							 .data_out(inM));
							 

single_port_ram cpu_ram(.a_clk(clk), 
                    .a_wr(we_ram), 
						  .a_addr(address_ram), 
						  .a_din(data_ram), 
						  .a_dout(data_ram_out));


// VGA memory						  
dual_port_ram video_ram(.a_clk(clk), 
                    .a_wr(we_screen), 
						  .a_addr(address_screen), 
						  .a_din(data_screen), 
						  //.a_dout(inM),
						  .b_clk(clk_vga),
						  //.b_wr(write_screen),
						  .b_addr(address_vga),
						  //.b_din(data_screen)
						  .b_dout(data_vga));



vga_controller vga_controller(
 .clk(clk), 
 .reset(rst), 
 .data_pixel(data_vga), 
 .address_pixel(address_vga),
 .clk_vga(clk_vga),
 .hsync(VGA_HS), 
 .vsync(VGA_VS), 
 .R(VGA_R), 
 .G(VGA_G), 
 .B(VGA_B));
 
 
// Dummy video filler (for testing)
//video_filler video_filler(
//.outM(outM), 
//.clk(clk),
//.writeM(writeM),
//.addressM(addressM));	

wire [15:0] instruction_wire;
wire [14:0] addressI;
wire loadPC, stall;

single_port_rom #(.PRG("C:/Users/g00621769/repos/nand2tetris/Verilog/nand2tetris/src/Memory/binaries/Mult.bin")) rom(.a_dout(instruction_wire), 
                    .a_addr(addressI), 
						  .a_clk(clk),
						  .stall(stall),
						  .jmp(loadPC));



// CPU
CPU CPU(.instruction(instruction_wire), 
        .inM(inM),
		  .reset(switchR),
		  .outM(outM),
		  .writeM(writeM),
		  .addressM(addressM),
		  .addressI(addressI),
		  .loadPC(loadPC),
		  .stall(stall),
		  .clk(clk),
		  .A(regA),
		  .D(regD));


keyboard keboard(.clk(clk), .ps2_clk(ps2_clk), .ps2_data(ps2_data), .out(key_pressed));

segment_display segment_display0(HEX0, key_pressed[3:0]);
segment_display segment_display1(HEX1, key_pressed[7:4]);

segment_display segment_display2(HEX2, regToDisplay[3:0]);
segment_display segment_display3(HEX3, regToDisplay[7:4]);
segment_display segment_display4(HEX4, regToDisplay[11:8]);
segment_display segment_display5(HEX5, regToDisplay[15:12]);


endmodule
