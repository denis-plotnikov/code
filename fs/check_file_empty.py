#!/usr/bin/python3.4
# finds the non-empty blocks in qcow2 file
# starting from the certain offset

import sys

CLUSTER_SIZE = 65536
BYTES = 8

f = sys.argv[1]
offset = int(sys.argv[2])

if offset & (CLUSTER_SIZE-1):
    print("Offset should be cluster_size({0}) aligned".format(CLUSTER_SIZE))
    sys.exit(22)

pos = offset

with open(f, 'rb') as f:
    f.seek(pos)

    while True: 
        data = f.read(BYTES)
        if not data:
            break
        val = int.from_bytes(data, byteorder = "big", signed = False)
        if val != 0:
            cluster = pos & ~(CLUSTER_SIZE-1)
            print("cluster: {0:#04x} offset: {1:#04x} val:{2:#08x}".
                   format(cluster, pos, val))
            pos = cluster + CLUSTER_SIZE
            f.seek(pos)
        else:
            pos += BYTES

print("Done!")
