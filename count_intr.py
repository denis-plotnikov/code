#!/usr/bin/python

import sys
import re

fname = sys.argv[1]

val_list = list()
rate_list = list()

with open(fname) as f:
	for line in f:
		try:
			p = line.index("RES")
			vals = line.split("   ")
			vals = [s.strip() for s in vals if len(s) > 0]
			val_list.append([int (v) for v in vals[1:9]])
		except:
			pass

		try:
			p = line.index("rate:")
			m = re.search("\d+", line[p:])
			if m:
				rate_list.append(int(m.group(0)))
		except:
			pass

calc_num = len(val_list)/2

for i in range(calc_num):
	s1 = sum(val_list[i*2])
	s2 = sum(val_list[i*2+1])
	s = s2 - s1
	
	v = [x-y for x, y in zip(val_list[i*2+1], val_list[i*2])]
	print("Intr: {0:10}\tRate: {1:10}".format(s, sum(rate_list)))
#	print("{0}:\t{1:10}".format(i+1, s))
	print "\t".join(map(str,v))
