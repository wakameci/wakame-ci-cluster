#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
lxc_count=${2}

COUNTER=0
while [  $COUNTER -lt ${lxc_count} ]; do
  let COUNTER=COUNTER+1    
  chroot ${chroot_dir} /bin/bash -ex <<EOS
    yum -y install tcpdump --installroot=/var/lib/lxc/lxc${COUNTER}/rootfs/
EOS
done

