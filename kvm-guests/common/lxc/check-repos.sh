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

chroot ${chroot_dir} /bin/bash -ex <<EOS
  yum install -y epel-release --installroot=/var/lib/lxc/lxc${lxc_suffix}/rootfs/
EOS



