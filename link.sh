python3 -m Jack.JackCompiler /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld
python3 -m VM.VMTranslator /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld
python3 -m Hack.hack /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld/HelloWorld.asm > /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld/HelloWorld.bin
for i in `ls Verilog/nand2tetris/src/test/HelloWorld/*.asm`; do wc -l $i; done
