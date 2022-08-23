import sys
import re
from argparse import ArgumentParser

symbol_table = {}

def init_symbol_table():
    symbol_table['SP'] = 0
    symbol_table['LCL'] = 1
    symbol_table['ARG'] = 2
    symbol_table['THIS'] = 3
    symbol_table['THAT'] = 4
    for i in range(0,16):
        regsymbol = 'R'+str(i)
        symbol_table[regsymbol] = i

    symbol_table['SCREEN'] = 16384
    symbol_table['KBD'] = 24576



def populate_symbol_table(program):
    pc = 0
    program_no_L = []

    # Add labels
    for instr in program:
        matchObj = re.match('\((.*)\)', instr)
        if matchObj:
            label = matchObj.group(1)
            symbol_table[label] = pc
        else:
            pc += 1
            program_no_L.append(instr)

    var_address = 16
    # Add variables
    for instr in program_no_L:
        if instr.startswith('@'):
            sym = instr[1:]
            if not sym.isnumeric() and (sym not in symbol_table):
                symbol_table[sym] = var_address
                var_address += 1

    return program_no_L



def dec2bin(dec, il=16):
    binstr = ''
    dec=int(dec)
    numzeros=il-1
    while True:
        binstr = str(dec % 2) + binstr
        dec=dec//2
        numzeros-=1
        if dec == 0:
            break

    
    return '0'*numzeros + binstr


def parse(instr):
    if instr.startswith('@'):
        address = instr[1:]
        if address.isnumeric():
            return (instr[1:],)
        else:
            return (symbol_table[address],)
    else:
        matchObj = re.match('(.*=)?([^;]*)(;.*)?$', instr)
        if matchObj:
            dest=matchObj.group(1)
            comp=matchObj.group(2).strip()
            jmp=matchObj.group(3)
            if dest:
                dest=dest[:-1].strip()
            if jmp:
                jmp=jmp[1:].strip()
            return (dest,comp,jmp)
        else:
            print("nothing found")

def decode_comp(comp):
    if comp == '0':
        return '0101010'
    if comp == '1':
        return '0111111'
    if comp == '-1':
        return '0111010'
    if comp == 'D':
        return '0001100'
    if comp == 'A':
        return '0110000'
    if comp == '!D':
        return '0001101'
    if comp == '!A':
        return '0110001'
    if comp == '-D':
        return '0001111'
    if comp == '-A':
        return '0110011'
    if comp == 'D+1':
        return '0011111'
    if comp == 'A+1':
        return '0110111'
    if comp == 'D-1':
        return '0001110'
    if comp == 'A-1':
        return '0110010'
    if comp == 'D+A':
        return '0000010'
    if comp == 'D-A':
        return '0010011'
    if comp == 'A-D':
        return '0000111'
    if comp == 'D&A':
        return '0000000'
    if comp =='D|A':
        return '0010101'
    if comp == 'M':
        return '1110000'
    if comp == '!M':
        return '1110001'
    if comp == '-M':
        return '1110011'
    if comp == 'M+1':
        return '1110111'
    if comp == 'M-1':
        return '1110010'
    if comp == 'D+M':
        return '1000010'
    if comp == 'D-M':
        return '1010011'
    if comp == 'M-D':
        return '1000111'
    if comp == 'D&M':
        return '1000000'
    if comp == 'D|M':
        return '1010101'
    print("ERROR! Computation not recognized")

def decode_dest(dest):
    if not dest:
        return '000'
    if dest=='M':
        return '001'
    if dest=='D':
        return '010'
    if dest=='MD':
        return '011'
    if dest=='A':
        return '100'
    if dest=='AM':
        return '101'
    if dest=='AD':
        return '110'
    if dest=='AMD':
        return '111'
    print("ERROR! Destination not recognized")

def decode_jmp(jmp):
    if not jmp:
        return '000'
    if jmp == 'JGT':
        return '001'
    if jmp == 'JEQ':
        return '010'
    if jmp == 'JGE':
        return '011'
    if jmp == 'JLT':
        return '100'
    if jmp == 'JNE':
        return '101'
    if jmp == 'JLE':
        return '110'
    if jmp == 'JMP':
        return '111'

def code(instr_tuple, il=16):
    if len(instr_tuple)==1:
        addr = instr_tuple[0]
        return '0' + dec2bin(addr,il)
    else:
        dest  = instr_tuple[0]
        comp = instr_tuple[1]
        jmp = instr_tuple[2]

        destcode = decode_dest(dest)
        compcode = decode_comp(comp)
        jmpcode = decode_jmp(jmp)
        fillcode = '111' if il==16 else '1111'
        return fillcode+compcode+destcode+jmpcode


def getprogam(fname):
    program = []
    f = open(fname,'r')
    for line in f:
        if line.startswith('//'):
            continue
        if line.isspace():
            continue
        instr=line.strip()
        instr = re.sub('\/\/.*$','',instr)
        instr.replace(' ', '')
        instr = instr.upper()
        program.append(instr)
    return program

def main():
    parser = ArgumentParser(description='A script to convert hack assembly to a binary file')

    parser.add_argument('infile', help='Input File', metavar='FILE')
    parser.add_argument('--il', type=int, default=16)
    args = parser.parse_args()
    program = getprogam(args.infile)

    init_symbol_table()
    program_no_L = populate_symbol_table(program)
        
    for instr in program_no_L:
        print(code(parse(instr),args.il))
        


if __name__=="__main__":
    main()

