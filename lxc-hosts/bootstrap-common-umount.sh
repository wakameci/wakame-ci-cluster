#!/bin/bash
#
# requires:
#  bash
#

umount -l ${rootfs_path}/dev/pts
umount -l ${rootfs_path}/dev
umount -l ${rootfs_path}/proc
