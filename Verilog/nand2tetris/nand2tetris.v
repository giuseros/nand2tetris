
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================
`timescale 1ps/1ps
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
//  Local parameters
//=======================================================

// Width of the instructions: 
// - original nand2tetris has 16 bits, which means that ROM can be 32K big
// - extended nand2tetris has 17 bits, whicn means that ROM can be 64K big

localparam IL = 17;
localparam PRG = "/mnt/data/nand2tetris/Verilog/nand2tetris/src/test/TestKeyboard/TestKeyboard.mif";


//=======================================================
//  REG/WIRE declarations
//=======================================================
reg sim_clk;

// Renaming 
wire rst, clk, clk50;
wire [7:0] key_pressed;
wire ps2_clk, ps2_data;

assign rst = ~(KEY[0]);
nand2tetris_pll PLL(
	.inclk0(MAX10_CLK1_50),
	.c0(clk));
	
assign clk50 = MAX10_CLK1_50;
//assign clk = sim_clk;

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
wire [15:0] data_screen_out;

wire [15:0] regA;
wire [15:0] regD;
wire [15:0] regToDisplay;

assign regToDisplay = (SW == 10'h0 ? 16'h0 : (SW == 10'h1 ? regD : regA));



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
							 .data_from_video(data_screen_out),
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
						  .a_dout(data_screen_out),
						  .b_clk(clk_vga),
						  //.b_wr(write_screen),
						  .b_addr(address_vga),
						  //.b_din(data_screen)
						  .b_dout(data_vga));



vga_controller vga_controller(
 .clk(clk50), 
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


wire [IL-1:0] instruction_wire;
wire [IL-2:0] addressI;
wire loadPC, stall;

// CPU
CPU #(.IL(IL), .PRG(PRG)) CPU( 
      .inM(inM),
		.reset(rst),
		.outM(outM),
		.writeM(writeM),
		.addressM(addressM),
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


// Use this only for simulation (it will slow down compilation)
//always
//#1 sim_clk = ~sim_clk;
//
//initial begin
//
//sim_clk = 1'b0;
//
//$monitor("%d] %d\nregD=%d-regA=%d",$time, $signed(instruction_wire), $signed(regD), $signed(regA));
//
//end

endmodule
