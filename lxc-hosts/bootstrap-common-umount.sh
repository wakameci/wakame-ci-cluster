#!/bin/bash
#
# requires:
#  bash
#

umount ${rootfs_path}/dev/pts
umount ${rootfs_path}/dev
umount ${rootfs_path}/proc
