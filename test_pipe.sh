#!/bin/bash
for i in {1..16}; do
	echo $i;
	grep RES /proc/interrupts > res;
	./at_process_ctxswitch_pipe -w -p $i -t 15 >> res;
	grep RES /proc/interrupts >> res;
	./count_intr.py res;
done
