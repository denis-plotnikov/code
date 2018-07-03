#!/bin/bash
VM=$1
QEMU_CMD="virsh qemu-monitor-command ${VM} --hmp"
 
set -x
prlctl stop ${VM} --kill
prlctl start ${VM}
sleep 120
${QEMU_CMD} stop
sleep 2
${QEMU_CMD} snapshot_blkdev drive-scsi0-0-0-0 /vzt/denis/the_snapshot
sleep 5
${QEMU_CMD} migrate_set_capability save-async on
${QEMU_CMD} migrate exec:write_file
sleep 30
#${QEMU_CMD} cont
