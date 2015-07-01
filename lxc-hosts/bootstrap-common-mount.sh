#!/bin/bash
#
# requires:
#  bash
#

mount -o bind /proc ${rootfs_path}/proc
mount -o bind /dev  ${rootfs_path}/dev
mount -o bind /dev/pts ${rootfs_path}/dev/pts
