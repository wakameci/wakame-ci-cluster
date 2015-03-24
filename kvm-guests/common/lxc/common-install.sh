#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
lxc_suffix=${2}
tools=${3}

arraylength=${#tools[@]}

for (( i=0; i<${arraylength}; i++ ));
do
  chroot ${chroot_dir} /bin/bash -ex <<EOS
    yum -y install "${tools[$i]}" --installroot=/var/lib/lxc/lxc${lxc_suffix}/rootfs/
EOS
done
