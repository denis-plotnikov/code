#!/bin/bash
VM=$1
QEMU_CMD="virsh qemu-monitor-command ${VM} --hmp"
 
set -x
prlctl start ${VM}
${QEMU_CMD} cont
