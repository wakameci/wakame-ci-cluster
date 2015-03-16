#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
lxc_suffix=${2}

# EPEL

file="/var/lib/lxc/lxc${lxc_suffix}/rootfs/etc/yum.repos.d/epel.repo"
if [ ! -f ${file} ]; then
  chroot ${chroot_dir} /bin/bash -ex <<EOS
    cp /etc/yum.repos.d/epel.repo ${file}
EOS
fi


