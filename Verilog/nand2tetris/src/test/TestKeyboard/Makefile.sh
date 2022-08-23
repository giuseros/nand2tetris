export PYTHONPATH=/mnt/data/nand2tetris/
IL=17
ROM_SIZE=60000
target=TestKeyboard
cp /mnt/data/nand2tetris/OS/*.jack .

python3 -m Jack.JackCompiler .
python3 -m VM.VMTranslator .
python3 -m Hack.hack --il=$IL $target.asm > $target.bin
python3 -m Hack.hack --il=$IL $target.asm > $target.hack
python3 -m Verilog.convert_to_mif -d $ROM_SIZE -w $IL $target.bin $target.mif
wc -l $target.asm
