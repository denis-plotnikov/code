#!/bin/bash
CNT=0
ITER=0

while (("$CNT" != 5)); do
	echo "Iteration #"$ITER
	virsh destroy vz7-L2; dmesg -c; virsh start vz7-L2; sleep 10; 
	CNT=`dmesg | grep "reading vcpu->arch.time" | wc -l`
        echo "cnt: "$CNT
	ITER=$((ITER+1))
done
echo "FOUND!"
