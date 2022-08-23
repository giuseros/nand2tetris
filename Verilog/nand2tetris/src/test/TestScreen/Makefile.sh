export PYTHONPATH=/mnt/data/nand2tetris/
IL=17
ROM_SIZE=60000

# This will work also if IL is 16. So we cannot use the entire OS otherwise that woouldn't fit in 32K
cp /mnt/data/nand2tetris/OS/Array.jack   .
cp /mnt/data/nand2tetris/OS/Math.jack    .
cp /mnt/data/nand2tetris/OS/Memory.jack  .
cp /mnt/data/nand2tetris/OS/Screen.jack  .
cp /mnt/data/nand2tetris/OS/String.jack  .

python3 -m Jack.JackCompiler .
python3 -m VM.VMTranslator .
python3 -m Hack.hack --il=$IL TestScreen.asm 
python3 -m Verilog.convert_to_mif -d $ROM_SIZE -w $IL TestScreen.hack TestScreen.mif
for i in `ls /mnt/data/nand2tetris/Verilog/nand2tetris/src/test/TestScreen/*.asm`; do wc -l $i; done