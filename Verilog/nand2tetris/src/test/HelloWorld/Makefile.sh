export PYTHONPATH=/mnt/data/nand2tetris/
IL=17
cp /mnt/data/nand2tetris/OS/Array.jack /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld/
cp /mnt/data/nand2tetris/OS/Math.jack /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld/
cp /mnt/data/nand2tetris/OS/Memory.jack /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld/
cp /mnt/data/nand2tetris/OS/Screen.jack /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld/
cp /mnt/data/nand2tetris/OS/String.jack /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld/

python3 -m Jack.JackCompiler /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld
python3 -m VM.VMTranslator /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld
python3 -m Hack.hack --il=$IL /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld/HelloWorld.asm > /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld/HelloWorld.bin
python3 -m Hack.hack --il=$IL /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld/HelloWorld.asm > /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld/HelloWorld.hack
python3 -m Verilog.convert_to_mif -d 60000 -w $IL /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld/HelloWorld.bin /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld/HelloWorld.mif
for i in `ls /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/HelloWorld/*.asm`; do wc -l $i; done
