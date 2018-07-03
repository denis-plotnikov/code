#!/bin/bash
set -x

# Input Vars
VM=$1
VM_HOST_NAME=$2
DEST=$3
DRIVE=$4

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

# Constants
QEMU_CMD="virsh qemu-monitor-command ${VM} "
DOMAIN_XML="${VM}.xml"
DEST_DIR="/tmp"
DEST_PATH="${DEST_DIR}/${DOMAIN_XML}"
MIGRATION_PORT=49152
SUCCESS=${GREEN}SUCCESS${NC}
FAILED=${RED}FAILED${NC}

function setup_capabilities {
        CMD=$1
	echo "${QEMU_CMD} '{\"execute\": \"migrate-set-capabilities\", \"arguments\": {\"capabilities\": [{\"state\": false, \"capability\": \"xbzrle\"}]}}'" | ${CMD}
	echo "${QEMU_CMD} '{\"execute\": \"migrate-set-capabilities\", \"arguments\": {\"capabilities\": [{\"state\": false, \"capability\": \"compress\"}]}}'" | ${CMD}
	echo "${QEMU_CMD} '{\"execute\": \"migrate-set-capabilities\", \"arguments\": {\"capabilities\": [{\"state\": false, \"capability\": \"auto-converge\"}]}}'" | ${CMD}
	echo "${QEMU_CMD} '{\"execute\": \"migrate-set-capabilities\", \"arguments\": {\"capabilities\": [{\"state\": false, \"capability\": \"rdma-pin-all\"}]}}'" | ${CMD}
	echo "${QEMU_CMD} '{\"execute\": \"migrate-set-capabilities\", \"arguments\": {\"capabilities\": [{\"state\": false, \"capability\": \"postcopy-ram\"}]}}'" | ${CMD}
	echo "${QEMU_CMD} '{\"execute\": \"migrate-set-capabilities\", \"arguments\": {\"capabilities\": [{\"state\": false, \"capability\": \"release-ram\"}]}}'" | ${CMD}
	echo "${QEMU_CMD} '{\"execute\": \"migrate-set-parameters\", \"arguments\": {\"tls-creds\": \"\", \"tls-hostname\": \"\"}}'" | ${CMD}
	echo "${QEMU_CMD} '{\"execute\": \"migrate_set_speed\", \"arguments\": {\"value\": 9223372036853727232}}'" | ${CMD}
}

# Preparation stage: stop the VMs on source and destonation 
virsh destroy ${VM}
ssh ${DEST} "virsh destroy ${VM}"

# Start VM on the source
virsh start ${VM}

# Get image path and file name with the given drive name
DRIVE_PATH=`${QEMU_CMD} --hmp info block ${DRIVE} | head -n 1| awk '{print $3}'`
DRIVE_FILE=`echo ${DRIVE_PATH} | sed 's:.*/::'`
DRIVE_DEVICE=`echo ${DRIVE} | sed "s/drive-//"`

if ((${#DRIVE_PATH}==0)); then
    echo "Can't find drive: "${DRIVE}" in VM: "${VM}
    echo -e ${FAILED}
    exit 1
fi

echo "Drive file found at "${DRIVE_PATH}

# Check if the drive image exists on the destination
IMAGE_EXISTS=`ssh ${DEST} "ls ${DRIVE_PATH}>/dev/null; echo $?"`
if (($IMAGE_EXISTS !=0 )); then
    echo "Can't find the disk image on the destination node with path "${DRIVE_PATH}
    echo "Please make sure it is there before starting the script next time"
    echo -e ${FAILED}
    exit 1
fi
   
echo "Drive file existance at the destination checked "${DRIVE_PATH}
echo "Starting the data writing script in the scource VM"
# Wait untill the VM loaded
sleep 30

# Start the script inside VM writing data to the disk
ssh ${VM_HOST_NAME} "/root/run.sh"
sleep 20

# Setup migration capabilities on the source VM
setup_capabilities "bash"

echo "Creating the destination VM"
# Create destination VM from the source VM
virsh dumpxml ${VM}>./${DOMAIN_XML}
sed -i "sD<qemu:arg value='handle_qmp_command'/>D<qemu:arg value='handle_qmp_command'/>\n<qemu:arg value='-incoming'/>\n<qemu:arg value='defer'/>D" ${DOMAIN_XML}

BL=`grep -Irn  "<disk type='file' device='disk'>" ${DOMAIN_XML} | awk '{print $1}'`
EL=`grep -Irn  "</disk>" ${DOMAIN_XML} | awk '{print $1}'`
sed -i "${BL},${EL}d" ${DOMAIN_XML}

scp ./${DOMAIN_XML} $DEST:${DEST_PATH}
rm ./${DOMAIN_XML}

ssh ${DEST} "virsh create ${DEST_PATH}"
#ssh ${DEST} "rm -rf ${DEST_PATH}"
ssh ${DEST} "${QEMU_CMD} --hmp drive_add dummy format=null-co,file=null-co://,if=none,id=${DRIVE},size=64G"
ssh ${DEST} "${QEMU_CMD} --hmp device_add scsi-hd,bus=scsi0.0,channel=0,scsi-id=0,lun=0,drive=${DRIVE},id=${DRIVE_DEVICE},bootindex=1"

# Setup migration capabilities on the destination VM
setup_capabilities "ssh ${DEST}"

# Start incomming migration on the destination VM
ssh ${DEST} "${QEMU_CMD} '{\"execute\": \"migrate-incoming\", \"arguments\": {\"uri\": \"tcp:0.0.0.0:${MIGRATION_PORT}\"}}'"
DEST_PID=`ssh ${DEST} ps aux | grep "guest=${VM}" | head -n 1 | awk '{print $2}'`
SOURCE_PID=`ps aux | grep "guest=${VM}" | head -n 1 | awk '{print $2}'`
ssh ${DEST} "${QEMU_CMD} --hmp stop"

#Check whether disk file is opened on the destination VM
ssh ${DEST} "ls -la /proc/${DEST_PID}/fd" | grep ${DRIVE_FILE}

# Start migration from the source VM
echo "Starting the migration"
${QEMU_CMD} "{\"execute\": \"migrate\", \"arguments\": {\"blk\": false, \"uri\": \"tcp:${DEST}:${MIGRATION_PORT}\", \"detach\": true, \"inc\": false}}"

# Wait until the migration finishes
sleep 20

# Remove the disk image on the SOURCE VM and check if the image file is closed
echo "Removing the drive file on the source VM"
ls -la /proc/${SOURCE_PID}/fd | grep ${DRIVE_FILE}
${QEMU_CMD} --hmp drive_del ${DRIVE}
ls -la /proc/${SOURCE_PID}/fd | grep ${DRIVE_FILE}

# Copy the image file from the source to the destination -- this step isn't needed with a shared disk
scp ${DRIVE_PATH} ${DEST}:${DRIVE_PATH}

# Set image file to the destination disk
# Assuming using standard qemu drive naming: "drive-<drive_controller_name>"
echo "Setting the drive file on the destination VM"
ssh ${DEST} "${QEMU_CMD} --hmp drive_del ${DRIVE}"
ssh ${DEST} "${QEMU_CMD} '{\"execute\":\"blockdev-change-medium\", \"arguments\": {\"id\":\"${DRIVE_DEVICE}\",  \"medium-name\":\"${DRIVE}\", \"filename\":\"${DRIVE_PATH}\"}}'"

# Check if the image file opened on the destination
ssh ${DEST} "ls -la /proc/${DEST_PID}/fd" | grep ${DRIVE_FILE}

# Resume the destination VM 
ssh ${DEST} "${QEMU_CMD} --hmp cont"

# Check if the destination VM is available
echo "Performing correctness checks"
ping -c 1 -w 10 ${VM_HOST_NAME}
RES=$?

if (($RES!=0)); then
    echo -e ${FAILED}
    exit 1
fi

sleep 60

# Check if the sript write.sh has written the data succesfully
RES=`ssh ${VM_HOST_NAME} "cat /root/tmp_file | wc -l"`

if (($RES==10000000)); then 
    echo -e ${SUCCESS}
else
    echo -e ${FAILED}
    exit 1
fi

exit 0
