#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
lxc_suffix=${2}

chroot ${chroot_dir} /bin/bash -ex <<EOS
  yum -y install nc --installroot=/var/lib/lxc/lxc${lxc_suffix}/rootfs/
EOS
