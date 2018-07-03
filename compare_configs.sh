#!/usr/bin/python

import sys

def get_params(fname):
	d = dict()
	with open(fname) as f:
		for line in f:
			l = line.strip()
			if (line[0] == '#'):
				continue
			param = line.split('=')
			v = ' '.join(param[1:])
			d[param[0]] = v.strip('\n') 
	return d

usage_text = "Compares boot configs of two kernels\n" \
	"Usage: {0} <filename1> <filename2>".format(sys.argv[0])
try:
	f1 = sys.argv[1]
	f2 = sys.argv[2]
except:
	print usage_text
	exit()

params1 = get_params(f1)
params2 = get_params(f2)

param_names = set([key for key in params1]) | set([key for key in params2])


the_first = True
f_output = "{0:80}{1:40}{2:40}"

for param in param_names:
	try:
		val1 = params1[param]
	except KeyError:
		val1 = '-'
		
	try:
		val2 = params2[param]
	except KeyError:
		val2 = '-'

	if (val1 != val2):
		if the_first:
			print(f_output.format("Param name", f1, f2))
			print "-"*140
			the_first = False

		print (f_output.format(param, val1, val2))
