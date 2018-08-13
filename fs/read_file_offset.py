#!/usr/bin/python

import sys

f = sys.argv[1]
offset = long(sys.argv[2])
length = long(sys.argv[3])

with open(f, 'r') as f:
    f.seek(offset)
    data = f.read(length)
    print(data)
