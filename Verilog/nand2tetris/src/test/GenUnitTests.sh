export PYTHONPATH=/mnt/data/nand2tetris/
IL=17
ROM_SIZE=60000

# Compile the VM tests
python3 -m VM.VMTranslator BasicLoop.vm
python3 -m VM.VMTranslator BasicTest.vm
python3 -m VM.VMTranslator FibonacciSeries.vm
python3 -m VM.VMTranslator PointerTest.vm
python3 -m VM.VMTranslator StaticTest.vm

# Compile all the asm files
python3 -m Hack.hack --il=$IL BasicLoop.asm
python3 -m Hack.hack --il=$IL BasicTest.asm
python3 -m Hack.hack --il=$IL FibonacciSeries.asm
python3 -m Hack.hack --il=$IL PointerTest.asm
python3 -m Hack.hack --il=$IL StaticTest.asm
python3 -m Hack.hack --il=$IL test_jmp.asm
python3 -m Hack.hack --il=$IL test_comp_D.asm
python3 -m Hack.hack --il=$IL test_mem.asm

# Generate the MIF for the board
python3 -m Verilog.convert_to_mif -d $ROM_SIZE -w $IL BasicLoop.hack BasicLoop.mif
python3 -m Verilog.convert_to_mif -d $ROM_SIZE -w $IL BasicTest.hack BasicTest.mif
python3 -m Verilog.convert_to_mif -d $ROM_SIZE -w $IL FibonacciSeries.hack FibonacciSeries.mif
python3 -m Verilog.convert_to_mif -d $ROM_SIZE -w $IL PointerTest.hack PointerTest.mif
python3 -m Verilog.convert_to_mif -d $ROM_SIZE -w $IL StaticTest.hack StaticTest.mif
python3 -m Verilog.convert_to_mif -d $ROM_SIZE -w $IL test_jmp.hack test_jmp.mif
python3 -m Verilog.convert_to_mif -d $ROM_SIZE -w $IL test_mem.hack test_mem.mif
python3 -m Verilog.convert_to_mif -d $ROM_SIZE -w $IL test_comp_D.hack test_comp_D.mif
