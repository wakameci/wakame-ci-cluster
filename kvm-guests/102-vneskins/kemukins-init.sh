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

  cat   metadata/ifcfg-${device} | tee ${mnt_path}/etc/sysconfig/network-scripts/ifcfg-${device}
}

function gen_network() {
  [[ -f metadata/network ]] || return 0

  cat   metadata/network | tee ${mnt_path}/etc/sysconfig/network
}

function gen_fstab() {
  [[ -f metadata/fstab ]] || return 0

  cat   metadata/fstab | tee ${mnt_path}/etc/fstab
}

function gen_yumrepo() {
  local repo=${1:-eth0}
  [[ -f metadata/${repo}.repo ]] || return 0

  cat   metadata/${repo}.repo | tee ${mnt_path}/etc/yum.repos.d/${repo}.repo
}

for ifname in metadata/ifcfg-*; do
  gen_ifcfg ${ifname##*/ifcfg-}
done
gen_network
gen_fstab
for repo in metadata/*.repo; do
  repo=${repo##*/}
  gen_yumrepo ${repo%%.repo}
done

if [[ -d execscript ]]; then
  while read line; do
    eval ${line} ${mnt_path}
  done < <(find -L execscript ! -type d -name '*.sh' | sort)
fi

if [[ -d guestroot ]]; then
  rsync -avx guestroot/ ${mnt_path}/
fi

sync

##

umount ${mnt_path}
kpartx -vd box-disk1.raw
