#!/bin/bash
set -x

VM=$1
FILE=$2
DRIVE=$3
DRIVE_DEVICE=`echo ${DRIVE} | sed "s/drive-//"`

PID=`ps aux | grep ${VM} | head -n 1 | awk '{print $2}'`

virsh qemu-monitor-command ${VM} --hmp stop

echo "disk fd before removing:"
ls -la /proc/$PID/fd | grep hdd

virsh qemu-monitor-command ${VM} --hmp drive_del ${DRIVE}

echo "disk fd after removing:"
ls -la /proc/$PID/fd | grep hdd
virsh qemu-monitor-command ${VM} --pretty '{"execute":"blockdev-change-medium", "arguments": {"id":"'${DRIVE_DEVICE}'",  "medium-name":"'${DRIVE}'", "filename":"'${FILE}'"}}'

echo "disk fd after replacing:"
ls -la /proc/$PID/fd | grep hdd

virsh qemu-monitor-command ${VM} --hmp cont
