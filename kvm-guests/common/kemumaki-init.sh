#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

mnt_path=mnt
raw=$(pwd)/box-disk1.raw

[[ -f ${raw} ]]
[[ $UID == 0 ]]

mkdir -p ${mnt_path}

output=$(kpartx -va ${raw})
loopdev_root=$(echo "${output}" | awk '{print $3}' | sed -n 1,1p) # loopXp1 should be "root".
loopdev_swap=$(echo "${output}" | awk '{print $3}' | sed -n 2,2p) # loopXp2 should be "swap".
[[ -n "${loopdev_root}" ]]
udevadm settle

devpath=/dev/mapper/${loopdev_root}
trap "
 umount -f ${mnt_path}/dev
 umount -f ${mnt_path}/proc
 umount -f ${mnt_path}
" ERR
mount ${devpath} ${mnt_path}
mount --bind /proc ${mnt_path}/proc
mount --bind /dev  ${mnt_path}/dev

## RHEL

function gen_ifcfg() {
  local device=${1:-eth0}
  [[ -f metadata/ifcfg-${device} ]] || return 0

  cat   metadata/ifcfg-${device} | tee ${mnt_path}/etc/sysconfig/network-scripts/ifcfg-${device}
}

function gen_route() {
  local device=${1:-eth0}
  [[ -f metadata/route-${device} ]] || return 0

  cat   metadata/route-${device} | tee ${mnt_path}/etc/sysconfig/network-scripts/route-${device}
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

function config_grub_console() {
  # grub1
  if [[ -f ${mnt_path}/boot/grub/grub.conf ]]; then
    sed -i 's/\(root=[^ ]*\) .*/\1 console=tty0 console=ttyS1/' ${mnt_path}/boot/grub/grub.conf
  fi

  # grub2
  if [[ -f ${mnt_path}/boot/grub2/grub.cfg ]]; then
    sed -i 's,^GRUB_CMDLINE_LINUX=.*,GRUB_CMDLINE_LINUX="console=tty0 console=ttyS1",' ${mnt_path}/etc/default/grub
    chroot ${mnt_path} grub2-mkconfig -o /boot/grub2/grub.cfg
  fi
}

for ifname in metadata/ifcfg-*; do
  gen_ifcfg ${ifname##*/ifcfg-}
  gen_route ${ifname##*/ifcfg-}
done
gen_network
gen_fstab
for repo in metadata/*.repo; do
  repo=${repo##*/}
  gen_yumrepo ${repo%%.repo}
done

config_grub_console

if [[ -d execscript ]]; then
  while read line; do
    eval ${line} ${mnt_path}
  done < <(find -L execscript ! -type d -name '*.sh' | sort)
fi

if [[ -d guestroot ]]; then
  rsync -avxSL guestroot/ ${mnt_path}/
fi

sync

##

umount ${mnt_path}/dev
umount ${mnt_path}/proc
umount ${mnt_path}
kpartx -vd ${raw}

sleep 3

function detach_partition() {
  local loopdev=${1}
  [[ -n "${loopdev}" ]] || return 0

  if dmsetup info ${loopdev} 2>/dev/null | egrep ^State: | egrep -w ACTIVE -q; then
    dmsetup remove ${loopdev}
  fi

  local loopdev_path=/dev/${loopdev%p[0-9]*}
  if losetup -a | egrep ^${loopdev_path}: -q; then
    losetup -d ${loopdev_path}
  fi
}

detach_partition ${loopdev_root}
detach_partition ${loopdev_swap}
