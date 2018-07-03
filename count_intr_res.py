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
			p = line.index("Result")
			m = re.search("\d+", line)
			if m:
				rate_list.append(m.group(0))
		except:
			pass

calc_num = len(val_list)/2

for i in range(calc_num):
	s1 = sum(val_list[i*2])
	s2 = sum(val_list[i*2+1])
	s = s2 - s1
	
	v = [x-y for x, y in zip(val_list[i*2+1], val_list[i*2])]
	print("{0}:\t{1:8}\t{2:8}".format(i+1, s, rate_list[i]))
#	print "\t".join(map(str,v))
