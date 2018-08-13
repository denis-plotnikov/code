#!/bin/bash
VM=$1
IP=$2
VMLOAD=${VM}-load
VM_QEMU_CMD="virsh qemu-monitor-command ${VM} --hmp"
VMLOAD_QEMU_CMD="virsh qemu-monitor-command ${VMLOAD} --hmp"

PAUSE_TIME=180
 
set -x
virsh destroy ${VM}
virsh destroy ${VMLOAD}

virsh start ${VM}

sleep $PAUSE_TIME

echo "Press any key to stop vm ..."
read

${VM_QEMU_CMD} stop
sleep 2
${VM_QEMU_CMD} snapshot_blkdev drive-scsi0-0-0-0 /vzt/denis/the_snapshot
sleep 5
#${VM_QEMU_CMD} migrate_set_capability background-snapshot on
${VM_QEMU_CMD} migrate_set_capability background-snapshot on

echo "Press any key to start snapshot ..."
read

${VM_QEMU_CMD} migrate exec:write_file
sleep 30

echo "Press any key to destroy vm  ..."
read

virsh destroy ${VM}
virsh start ${VMLOAD}
sleep 30
${VMLOAD_QEMU_CMD} cont

ping ${IP} -c 1 -W 5
RES=$?

if (($RES==0)); then
    TIME=`ssh ${IP} "uptime" | awk '{print $3}'`
    if (($TIME==$((PAUSE_TIME/60)))); then
        prlctl stop ${VMLOAD}
        echo "[PASS]"
        exit 0
   fi
fi

echo "[FAILED]"
exit 1
