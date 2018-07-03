#!/bin/bash
set -x
rmmod kvm_intel && rmmod kvm
insmod /vz/vzkernel/arch/x86/kvm/kvm.ko && insmod /vz/vzkernel/arch/x86/kvm/kvm-intel.ko 
dmesg -c > /dev/null
virsh start vz7-L2
sleep 10
virsh qemu-monitor-command vz7-L2 --hmp gdbserver
ps aux | grep qemu
