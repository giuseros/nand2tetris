export PYTHONPATH=/mnt/data/nand2tetris/
IL=17
ROM_SIZE=60000
target=Square
cp /mnt/data/nand2tetris/OS/*.jack .

python3 -m Jack.JackCompiler .
python3 -m VM.VMTranslator .
python3 -m Hack.hack --il=$IL $target.asm
wc -l $target.asm


python3 -m Verilog.convert_to_mif -d $ROM_SIZE -w $IL $target.hack $target.mif
