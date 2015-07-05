#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -u
set -x

raw="${1:-"blank.raw"}"
disk_size="${disk_size:-"1024"}"

if ! [[ "${UID}" == 0 ]]; then
  echo "[ERROR] Must run as root." >&2
  exit 1
fi

# -1
dmsetup ls
udevadm settle

# 0
truncate -s "${disk_size}m" "${raw}"

# 1
parted --script "${raw}" -- mklabel msdos
parted --script "${raw}" -- unit s print

# 2
parted --script "${raw}" -- mkpart primary ext2 63s -0
parted --script "${raw}" -- unit s print

# 3
output="$(kpartx -va "${raw}")"
loopdev_root="$(echo "${output}" | awk '{print $3}' | sed -n 1,1p)" # loopXp1 should be "root".
udevadm settle

mkfs.ext4 -F -E lazy_itable_init=1 "/dev/mapper/${loopdev_root}"
mkdir -p mnt
mount "/dev/mapper/${loopdev_root}" mnt
df -k
df -m
df -h
umount mnt
rmdir mnt

# 4
kpartx -vd "${raw}"

# 5
# remove DM and loop devices associated with the raw image.
function detach_raw() {
  local raw_path="${1}"

  kpartx -vd "${raw_path}"

  local loop_path=
  for loop_path in $(losetup --associated "${raw_path}" | awk -F\: '{print $1}'); do
    local loop_name="${loop_path#/dev/}"
    # list and remove /dev/mapper dependants of the loop device.
    for dm in $(dmsetup deps | grep "${loop_name}p" | awk -F\: '{print $1}'); do
      dmsetup remove "/dev/mapper/${dm}"
      echo "Detached DM device: /dev/mapper/${dm}"
    done
    udevadm settle

    losetup -d "${loop_path}"
    echo "Detached loop device: ${loop_path}"
  done
}

detach_raw "${raw}"

# 6
rm -f "${raw}"
