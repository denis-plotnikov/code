#!/bin/bash
VM=$1

set -x
virsh qemu-monitor-command ${VM} '{"execute":"x-block-set-copy-on-read", "arguments": {"device": "drive-scsi0-0-1-0234234", "enable": false}}'

virsh qemu-monitor-command ${VM} '{"execute":"x-block-set-copy-on-read", "arguments": {"device": "drive-scsi0-0-0-0", "enable": false}}'

virsh qemu-monitor-command ${VM} '{"execute":"x-block-set-copy-on-read", "arguments": {"device": "drive-scsi0-0-0-0", "enable": true}}'
virsh qemu-monitor-command ${VM} '{"execute":"x-block-set-copy-on-read", "arguments": {"device": "drive-scsi0-0-0-0", "enable": true}}'

virsh qemu-monitor-command ${VM} '{"execute":"x-block-set-copy-on-read", "arguments": {"device": "drive-scsi0-0-0-0", "enable": false}}'

virsh qemu-monitor-command ${VM} '{"execute":"x-block-set-copy-on-read", "arguments": {"device": "drive-scsi0-0-0-0", "enable": false}}'


virsh qemu-monitor-command ${VM} '{"execute":"x-block-set-copy-on-read", "arguments": {"device": "drive-scsi0-0-1-0", "enable": true}}'
