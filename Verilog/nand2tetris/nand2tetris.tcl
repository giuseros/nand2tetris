# Copyright (C) 2016  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel MegaCore Function License Agreement, or other 
# applicable license agreement, including, without limitation, 
# that your use is for the sole purpose of programming logic 
# devices manufactured by Intel and sold by Intel or its 
# authorized distributors.  Please refer to the applicable 
# agreement for further details.

# Quartus Prime: Generate Tcl File for Project
# File: nand2tetris.tcl
# Generated on: Sat Jul 09 23:57:52 2022

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "nand2tetris"]} {
		puts "Project nand2tetris is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists nand2tetris]} {
		project_open -revision nand2tetris nand2tetris
	} else {
		project_new -revision nand2tetris nand2tetris
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "MAX 10 FPGA"
	set_global_assignment -name DEVICE 10M50DAF484C7G
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 16.0.0
	set_global_assignment -name LAST_QUARTUS_VERSION "16.1.0 Lite Edition"
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "01:09:14 JULY 05,2022"
	set_global_assignment -name DEVICE_FILTER_PACKAGE FBGA
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT 484
	set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 7
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name VERILOG_FILE src/segment_display.v
	set_global_assignment -name VERILOG_FILE src/Video/vga_controller.v
	set_global_assignment -name VERILOG_FILE src/Memory/single_port_rom.v
	set_global_assignment -name VERILOG_FILE src/Memory/single_port_ram.v
	set_global_assignment -name VERILOG_FILE src/Memory/dual_port_ram.v
	set_global_assignment -name VERILOG_FILE src/Memory/arbitrator.v
	set_global_assignment -name VERILOG_FILE src/Keyboard/keyboard.v
	set_global_assignment -name VERILOG_FILE src/Keyboard/debouncer.v
	set_global_assignment -name VERILOG_FILE src/CPU/video_filler.v
	set_global_assignment -name VERILOG_FILE src/CPU/Decoder.v
	set_global_assignment -name VERILOG_FILE src/CPU/CPU.v
	set_global_assignment -name VERILOG_FILE src/CPU/ALU.v
	set_global_assignment -name SDC_FILE nand2tetris.SDC
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ADC_CLK_10
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to MAX10_CLK1_50
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to MAX10_CLK2_50
	set_location_assignment PIN_N5 -to ADC_CLK_10
	set_location_assignment PIN_P11 -to MAX10_CLK1_50
	set_location_assignment PIN_N14 -to MAX10_CLK2_50
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[7]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[7]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[7]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[7]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX4[7]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX5[7]
	set_location_assignment PIN_C14 -to HEX0[0]
	set_location_assignment PIN_E15 -to HEX0[1]
	set_location_assignment PIN_C15 -to HEX0[2]
	set_location_assignment PIN_C16 -to HEX0[3]
	set_location_assignment PIN_E16 -to HEX0[4]
	set_location_assignment PIN_D17 -to HEX0[5]
	set_location_assignment PIN_C17 -to HEX0[6]
	set_location_assignment PIN_D15 -to HEX0[7]
	set_location_assignment PIN_C18 -to HEX1[0]
	set_location_assignment PIN_D18 -to HEX1[1]
	set_location_assignment PIN_E18 -to HEX1[2]
	set_location_assignment PIN_B16 -to HEX1[3]
	set_location_assignment PIN_A17 -to HEX1[4]
	set_location_assignment PIN_A18 -to HEX1[5]
	set_location_assignment PIN_B17 -to HEX1[6]
	set_location_assignment PIN_A16 -to HEX1[7]
	set_location_assignment PIN_B20 -to HEX2[0]
	set_location_assignment PIN_A20 -to HEX2[1]
	set_location_assignment PIN_B19 -to HEX2[2]
	set_location_assignment PIN_A21 -to HEX2[3]
	set_location_assignment PIN_B21 -to HEX2[4]
	set_location_assignment PIN_C22 -to HEX2[5]
	set_location_assignment PIN_B22 -to HEX2[6]
	set_location_assignment PIN_A19 -to HEX2[7]
	set_location_assignment PIN_F21 -to HEX3[0]
	set_location_assignment PIN_E22 -to HEX3[1]
	set_location_assignment PIN_E21 -to HEX3[2]
	set_location_assignment PIN_C19 -to HEX3[3]
	set_location_assignment PIN_C20 -to HEX3[4]
	set_location_assignment PIN_D19 -to HEX3[5]
	set_location_assignment PIN_E17 -to HEX3[6]
	set_location_assignment PIN_D22 -to HEX3[7]
	set_location_assignment PIN_F18 -to HEX4[0]
	set_location_assignment PIN_E20 -to HEX4[1]
	set_location_assignment PIN_E19 -to HEX4[2]
	set_location_assignment PIN_J18 -to HEX4[3]
	set_location_assignment PIN_H19 -to HEX4[4]
	set_location_assignment PIN_F19 -to HEX4[5]
	set_location_assignment PIN_F20 -to HEX4[6]
	set_location_assignment PIN_F17 -to HEX4[7]
	set_location_assignment PIN_J20 -to HEX5[0]
	set_location_assignment PIN_K20 -to HEX5[1]
	set_location_assignment PIN_L18 -to HEX5[2]
	set_location_assignment PIN_N18 -to HEX5[3]
	set_location_assignment PIN_M20 -to HEX5[4]
	set_location_assignment PIN_N19 -to HEX5[5]
	set_location_assignment PIN_N20 -to HEX5[6]
	set_location_assignment PIN_L19 -to HEX5[7]
	set_instance_assignment -name IO_STANDARD "3.3 V SCHMITT TRIGGER" -to KEY[0]
	set_instance_assignment -name IO_STANDARD "3.3 V SCHMITT TRIGGER" -to KEY[1]
	set_location_assignment PIN_B8 -to KEY[0]
	set_location_assignment PIN_A7 -to KEY[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[7]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[8]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDR[9]
	set_location_assignment PIN_A8 -to LEDR[0]
	set_location_assignment PIN_A9 -to LEDR[1]
	set_location_assignment PIN_A10 -to LEDR[2]
	set_location_assignment PIN_B10 -to LEDR[3]
	set_location_assignment PIN_D13 -to LEDR[4]
	set_location_assignment PIN_C13 -to LEDR[5]
	set_location_assignment PIN_E14 -to LEDR[6]
	set_location_assignment PIN_D14 -to LEDR[7]
	set_location_assignment PIN_A11 -to LEDR[8]
	set_location_assignment PIN_B11 -to LEDR[9]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[7]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[8]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[9]
	set_location_assignment PIN_C10 -to SW[0]
	set_location_assignment PIN_C11 -to SW[1]
	set_location_assignment PIN_D12 -to SW[2]
	set_location_assignment PIN_C12 -to SW[3]
	set_location_assignment PIN_A12 -to SW[4]
	set_location_assignment PIN_B12 -to SW[5]
	set_location_assignment PIN_A13 -to SW[6]
	set_location_assignment PIN_A14 -to SW[7]
	set_location_assignment PIN_B14 -to SW[8]
	set_location_assignment PIN_F15 -to SW[9]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_B[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_B[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_B[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_B[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_G[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_G[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_G[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_G[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_HS
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_R[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_R[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_R[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_R[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_VS
	set_location_assignment PIN_P1 -to VGA_B[0]
	set_location_assignment PIN_T1 -to VGA_B[1]
	set_location_assignment PIN_P4 -to VGA_B[2]
	set_location_assignment PIN_N2 -to VGA_B[3]
	set_location_assignment PIN_W1 -to VGA_G[0]
	set_location_assignment PIN_T2 -to VGA_G[1]
	set_location_assignment PIN_R2 -to VGA_G[2]
	set_location_assignment PIN_R1 -to VGA_G[3]
	set_location_assignment PIN_N3 -to VGA_HS
	set_location_assignment PIN_AA1 -to VGA_R[0]
	set_location_assignment PIN_V1 -to VGA_R[1]
	set_location_assignment PIN_Y2 -to VGA_R[2]
	set_location_assignment PIN_Y1 -to VGA_R[3]
	set_location_assignment PIN_N1 -to VGA_VS
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[7]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[8]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[9]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[10]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[11]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[12]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[13]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[14]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[15]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[16]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[17]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[18]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[19]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[20]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[21]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[22]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[23]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[24]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[25]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[26]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[27]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[28]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[29]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[30]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[31]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[32]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[33]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[34]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to nand2tetrisGPIO[35]
	set_location_assignment PIN_V10 -to nand2tetrisGPIO[0]
	set_location_assignment PIN_W10 -to nand2tetrisGPIO[1]
	set_location_assignment PIN_V9 -to nand2tetrisGPIO[2]
	set_location_assignment PIN_W9 -to nand2tetrisGPIO[3]
	set_location_assignment PIN_V8 -to nand2tetrisGPIO[4]
	set_location_assignment PIN_W8 -to nand2tetrisGPIO[5]
	set_location_assignment PIN_V7 -to nand2tetrisGPIO[6]
	set_location_assignment PIN_W7 -to nand2tetrisGPIO[7]
	set_location_assignment PIN_W6 -to nand2tetrisGPIO[8]
	set_location_assignment PIN_V5 -to nand2tetrisGPIO[9]
	set_location_assignment PIN_W5 -to nand2tetrisGPIO[10]
	set_location_assignment PIN_AA15 -to nand2tetrisGPIO[11]
	set_location_assignment PIN_AA14 -to nand2tetrisGPIO[12]
	set_location_assignment PIN_W13 -to nand2tetrisGPIO[13]
	set_location_assignment PIN_W12 -to nand2tetrisGPIO[14]
	set_location_assignment PIN_AB13 -to nand2tetrisGPIO[15]
	set_location_assignment PIN_AB12 -to nand2tetrisGPIO[16]
	set_location_assignment PIN_Y11 -to nand2tetrisGPIO[17]
	set_location_assignment PIN_AB11 -to nand2tetrisGPIO[18]
	set_location_assignment PIN_W11 -to nand2tetrisGPIO[19]
	set_location_assignment PIN_AB10 -to nand2tetrisGPIO[20]
	set_location_assignment PIN_AA10 -to nand2tetrisGPIO[21]
	set_location_assignment PIN_AA9 -to nand2tetrisGPIO[22]
	set_location_assignment PIN_Y8 -to nand2tetrisGPIO[23]
	set_location_assignment PIN_AA8 -to nand2tetrisGPIO[24]
	set_location_assignment PIN_Y7 -to nand2tetrisGPIO[25]
	set_location_assignment PIN_AA7 -to nand2tetrisGPIO[26]
	set_location_assignment PIN_Y6 -to nand2tetrisGPIO[27]
	set_location_assignment PIN_AA6 -to nand2tetrisGPIO[28]
	set_location_assignment PIN_Y5 -to nand2tetrisGPIO[29]
	set_location_assignment PIN_AA5 -to nand2tetrisGPIO[30]
	set_location_assignment PIN_Y4 -to nand2tetrisGPIO[31]
	set_location_assignment PIN_AB3 -to nand2tetrisGPIO[32]
	set_location_assignment PIN_Y3 -to nand2tetrisGPIO[33]
	set_location_assignment PIN_AB2 -to nand2tetrisGPIO[34]
	set_location_assignment PIN_AA2 -to nand2tetrisGPIO[35]
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
