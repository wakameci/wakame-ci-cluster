#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

mnt_path=${mnt_path:-mnt}
# remove tail "/".
mnt_path=${mnt_path%/}
raw=${raw:-$(pwd)/box-disk1.raw}

kpartx_output=

function attach_raw() {
  local raw_path=$1

  kpartx_output="$(kpartx -va ${raw_path})"
  udevadm settle
}

function mount_raw() {
  local raw_path=$1 mnt_path=$2

  loopdev_root=$(echo "${kpartx_output}" | awk '{print $3}' | sed -n 1,1p) # loopXp1 should be "root".
  loopdev_swap=$(echo "${kpartx_output}" | awk '{print $3}' | sed -n 2,2p) # loopXp2 should be "swap".
  [[ -n "${loopdev_root}" ]]

  local devpath=/dev/mapper/${loopdev_root}
  trap "
   umount -f ${mnt_path}/dev
   umount -f ${mnt_path}/proc
   umount -f ${mnt_path}
  " ERR

  mkdir -p ${mnt_path}

  mount ${devpath}   ${mnt_path}
  mount --bind /proc ${mnt_path}/proc
  mount --bind /dev  ${mnt_path}/dev
}

function umount_raw() {
  local raw_path=$1 mnt_path=$2

  umount ${mnt_path}/dev
  umount ${mnt_path}/proc
  umount ${mnt_path}

  rmdir  ${mnt_path}
}

# remove DM and loop devices associated with the raw image.
function detach_raw() {
  local raw_path=$1

  kpartx -vd ${raw_path}

  local loop_path=
  for loop_path in $(losetup --associated ${raw_path} | awk -F\: '{print $1}'); do
    local loop_name=${loop_path#/dev/}
    # list and remove /dev/mapper dependants of the loop device.
    for dm in $(dmsetup deps | grep "${loop_name}p" | awk -F\: '{print $1}'); do
      dmsetup remove "/dev/mapper/${dm}"
      echo "Detached DM device: /dev/mapper/${dm}"
    done
    udevadm settle

    losetup -d $loop_path
    echo "Detached loop device: ${loop_path}"
  done
}

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

function render_tty_conf() {
  cat <<-'EOS'
	# tty - getty
	#
	# This service maintains a getty on the specified device.

	stop on runlevel [S016]

	respawn
	instance $TTY
	#exec /sbin/mingetty $TTY
	script
	    if [[ "$TTY" == "/dev/ttyS0" ]]; then
	      exec /sbin/mingetty --autologin=root $TTY
	    else
	      exec /sbin/mingetty $TTY
	    fi
	end script
	usage 'tty TTY=/dev/ttyX  - where X is console id'
	EOS
}

function render_autologin_conf() {
  cat <<-'EOS'
	[Service]
	ExecStart=
	ExecStart=-/sbin/agetty --autologin=root -s %I
	EOS
}

function config_tty() {
  # upstart
  if [[ -f ${mnt_path}/etc/init/tty.conf ]]; then
    render_tty_conf | tee ${mnt_path}/etc/init/tty.conf
  fi

  # systemd
  if [[   -d ${mnt_path}/etc/systemd/system/getty.target.wants ]]; then
    mkdir -p ${mnt_path}/etc/systemd/system/getty\@ttyS0.service.d
    render_autologin_conf | tee ${mnt_path}/etc/systemd/system/getty\@ttyS0.service.d/autologin.conf
  fi
}

##

if ! [[ -f ${raw} ]]; then
  echo "[ERROR] No such file: ${raw}" >&2
  exit 1
fi

if ! [[ $UID == 0 ]]; then
  echo "[ERROR] Must run as root." >&2
  exit 1
fi

##

attach_raw ${raw}
mount_raw  ${raw} ${mnt_path}

{
for ifname in metadata/ifcfg-*; do
  gen_ifcfg ${ifname##*/ifcfg-}
  gen_route ${ifname##*/ifcfg-}
done
gen_network
gen_fstab

config_grub_console
config_tty

if [[ -d guestroot ]]; then
  rsync -avxSL guestroot/ ${mnt_path}/
fi

if [[ -d execscript ]]; then
  while read line; do
    eval ${line} ${mnt_path}
  done < <(find -L execscript ! -type d -perm -a=x | sort)
fi

sync
}

##

umount_raw ${raw} ${mnt_path}
detach_raw ${raw}
