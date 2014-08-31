#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x
set -o pipefail

mnt_path=mnt

[[ -f box-disk1.raw ]]
[[ $UID == 0 ]]

mkdir -p ${mnt_path}

output=$(kpartx -va box-disk1.raw)
loopdev=$(echo "${output}" | awk '{print $3}')
[[ -n "${loopdev}" ]]
udevadm settle

devpath=/dev/mapper/${loopdev}
mount ${devpath} ${mnt_path}

## RHEL

function gen_ifcfg() {
  local device=${1:-eth0}
  [[ -f metadata/ifcfg-${device} ]] || return 0
  .     metadata/ifcfg-${device}

  cat <<-EOS | tee ${mnt_path}/etc/sysconfig/network-scripts/ifcfg-${device}
	DEVICE=${device}
	TYPE=${TYPE:-Ethernet}
	BOOTPROTO=${BOOTPROTO:-static}
	ONBOOT=${ONBOOT:-yes}
	IPADDR=${IPADDR}
	NETMASK=${NETMASK:-255.255.255.0}
	GATEWAY=${GATEWAY}
	DNS1=${DNS1:-8.8.8.8}
	EOS
}

function gen_network() {
  [[ -f metadata/network ]] || return 0
  .     metadata/network

  cat <<-EOS | tee ${mnt_path}/etc/sysconfig/network
	NETWORKING=yes
	HOSTNAME=${HOSTNAME:-localhost}
	EOS
}

function gen_fstab() {
  [[ -f metadata/fstab ]] || return 0

  cat   metadata/fstab | tee ${mnt_path}/etc/fstab
}

gen_ifcfg eth0
gen_network
gen_fstab
sync

##

umount ${mnt_path}
kpartx -vd box-disk1.raw
