export PYTHONPATH=/mnt/data/nand2tetris/
IL=17
ROM_SIZE=60000
cp /mnt/data/nand2tetris/OS/Array.jack /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/TestScreen/
cp /mnt/data/nand2tetris/OS/Math.jack /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/TestScreen/
cp /mnt/data/nand2tetris/OS/Memory.jack /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/TestScreen/
cp /mnt/data/nand2tetris/OS/Screen.jack /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/TestScreen/
cp /mnt/data/nand2tetris/OS/String.jack /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/TestScreen/

python3 -m Jack.JackCompiler /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/TestScreen
python3 -m VM.VMTranslator /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/TestScreen
python3 -m Hack.hack --il=$IL /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/TestScreen/TestScreen.asm > /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/TestScreen/TestScreen.bin
python3 -m Hack.hack --il=$IL /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/TestScreen/TestScreen.asm > /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/TestScreen/TestScreen.hack
python3 -m Verilog.convert_to_mif -d $ROM_SIZE -w $IL /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/TestScreen/TestScreen.bin /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/TestScreen/TestScreen.mif
for i in `ls /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/TestScreen/*.asm`; do wc -l $i; done
