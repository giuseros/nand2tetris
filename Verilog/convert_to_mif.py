#!/usr/bin/env python
import sys
from argparse import ArgumentParser

parser = ArgumentParser(description='A script to convert binary assembly to a mif file')

parser.add_argument('infile', help='Input File', metavar='FILE')
parser.add_argument('outfile', help='Output Assembly File', metavar='FILE')

parser.add_argument('-d', '--depth', type=int, default=1024)
parser.add_argument('-w', '--width', type=int, default=32)
parser.add_argument('-r', '--radix', type=str, default="DEC")
parser.add_argument('-dr', '--data-radix', metavar='RADIX', type=str, default='BIN')
parser.add_argument('-m', '--max-instructions', type=int, default='63')
args = parser.parse_args()

with open(args.infile, 'r') as binary_text:
  with open(args.outfile, 'w') as mif_file:
    mif_file.write('DEPTH={};\n'.format(args.depth))
    mif_file.write('WIDTH = {};\n'.format(args.width))
    mif_file.write('ADDRESS_RADIX = {};\n'.format(args.radix))
    mif_file.write('DATA_RADIX = {};\n\n'.format(args.data_radix))
    mif_file.write('CONTENT\n')
    mif_file.write('BEGIN\n')

    inst_num = 0
    for instruction in binary_text:
      mif_file.write('{0}: {1};\n'.format(inst_num, instruction.strip()))
      inst_num += 1

    mif_file.write('[{0}..{1}] : 00000000; END;\n'.format(inst_num, args.max_instructions))
