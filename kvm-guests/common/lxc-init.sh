#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
centos_ver=${2}
lxc_count=${3}

COUNTER=0
while [  $COUNTER -lt ${lxc_count} ]; do
  let COUNTER=COUNTER+1    
  chroot ${chroot_dir} /bin/bash -ex <<EOS
    lxc-create -t centos -n lxc${COUNTER} -- -R ${centos_ver}
    echo root:root | sudo chroot /var/lib/lxc/lxc${COUNTER}/rootfs chpasswd
EOS
done

echo $PWD
. ../common/lxc/iperf3.sh ${chroot_dir} ${centos_ver} ${lxc_count}
