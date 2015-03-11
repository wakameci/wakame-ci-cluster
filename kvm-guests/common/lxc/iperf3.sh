#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
lxc_suffix=${2}
file=iperf3-3.0.10-1.el6.x86_64.rpm

if [ ! -f ${file} ]; then
  chroot ${chroot_dir} /bin/bash -ex <<EOS
    wget http://dl.fedoraproject.org/pub/epel/6/x86_64/${file}
EOS
fi

chroot ${chroot_dir} /bin/bash -ex <<EOS
  rpm -i --root=/var/lib/lxc/lxc${lxc_suffix}/rootfs --nodeps ${file}
EOS

