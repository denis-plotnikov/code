#!/bin/bash
set -x
TYPE=$1
QEMU_BIN=$2
DISK_PATH=$3

if [ ${TYPE} == scsi ]; then
    DISK_DEV="scsi-hd,bus=scsi0.0,channel=0,scsi-id=0,lun=0,id=scsi0-0-0-0"
elif [ ${TYPE} == ide ]; then
    DISK_DEV="ide-hd,bus=ide.1,unit=0,id=ide0-1-0"
else
    echo "Unknown interface format: ${TYPE}. Available: scsi, ide"
    exit
fi


VM_NAME="blockfreeze"

${QEMU_BIN} \
 -name guest=${VM_NAME},debug-threads=on \
 -machine pc,accel=kvm,usb=off,dump-guest-core=off \
 -cpu Haswell-noTSX,vme=on,ss=on,vmx=off,pcid=on,hypervisor=on,arat=off,tsc_adjust=on,xsaveopt=on,pdpe1gb=on,ds=on,acpi=on,ht=on,tm=on,pbe=on,dtes64=on,monitor=on,ds_cpl=on,smx=on,est=on,tm2=on,xtpr=on,pdcm=on,dca=on,osxsave=on,vmx=off,+kvmclock \
 -m 2048 \
 -realtime mlock=off \
 -smp 2,sockets=1,cores=2,threads=1 \
 -uuid 28417066-a282-43c7-9bd9-627905131313 \
 -nodefaults \
 -no-user-config \
 -chardev stdio,id=charmonitor \
 -mon chardev=charmonitor,id=monitor,mode=readline \
 -global kvm-pit.lost_tick_policy=discard \
 -boot strict=on \
 -device nec-usb-xhci,id=usb,bus=pci.0,addr=0x6 \
 -device virtio-scsi-pci,id=scsi0,bus=pci.0,addr=0x5 \
 -device virtio-serial-pci,id=virtio-serial0,bus=pci.0,addr=0x7 \
 -drive file=${DISK_PATH},format=qcow2,if=none,id=hard-drive-0,serial=4f1721bd927c40ac9135,cache=none,discard=unmap,aio=native \
 -device ${DISK_DEV},drive=hard-drive-0,bootindex=1\
 -netdev tap,ifname=tap1,id=hostnet0,vhost=on,script=no,downscript=no \
 -device virtio-net-pci,netdev=hostnet0,id=net0,mac=00:1c:42:9f:13:13,bus=pci.0,addr=0x3,bootindex=3 \
 -chardev file,id=charserial0,path=/tmp/${VM_NAME}-serial.txt,append=on \
 -device isa-serial,chardev=charserial0,id=serial0 \
 -device usb-tablet,id=input0,bus=usb.0,port=1 \
 -vnc 0.0.0.0:5901,websocket=5700 \
 -device VGA,id=video0,vgamem_mb=32,bus=pci.0,addr=0x2 \
 -d guest_errors,unimp \
 -device pvpanic,ioport=1285 \
 -msg timestamp=on
