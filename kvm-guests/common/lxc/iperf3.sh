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

chroot ${chroot_dir} /bin/bash -ex <<EOS
  wget http://dl.fedoraproject.org/pub/epel/6/x86_64/iperf3-3.0.10-1.el6.x86_64.rpm  
EOS

COUNTER=0
while [  $COUNTER -lt ${lxc_count} ]; do
  let COUNTER=COUNTER+1    
  chroot ${chroot_dir} /bin/bash -ex <<EOS
    rpm -i --root=/var/lib/lxc/lxc${COUNTER}/rootfs --nodeps iperf3-3.0.10-1.el6.x86_64.rpm
EOS
done

