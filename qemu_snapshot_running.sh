#!/bin/bash
VM=$1
QEMU_CMD="virsh qemu-monitor-command ${VM} --hmp"
 
set -x
${QEMU_CMD} migrate exec:write_file
