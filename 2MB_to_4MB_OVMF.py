#!/usr/bin/python2
import sys

skip_bytes = 100
_2mb_area_lens_kb = [56 * 1024 - skip_bytes, 4 * 1024, 4 * 1024, 64 * 1024]
_4mb_area_lens_kb = [256 * 1024 - skip_bytes, 4 * 1024, 4 * 1024, 264 * 1024]

source_file = sys.argv[1]
dest_file = sys.argv[2]

print "Source file: {0}".format(source_file)

source = open(source_file,"rb")
dest = open(dest_file,"rb+")

source.seek(skip_bytes)
dest.seek(skip_bytes)

for area_size in zip(_2mb_area_lens_kb, _4mb_area_lens_kb):
    part_len = area_size[0]
    part = source.read(part_len)
    dest.write(part)
    rest = area_size[1] - part_len
    dest.write(bytearray([0xFF for i in range(0, rest)]))

dest.close()
source.close()
