#!/bin/bash
for i in {1..20}; do
	echo "Testcase == $i";
	grep RES /proc/interrupts;
	./threads $i 30 | grep Result;
        grep RES /proc/interrupts;
done
