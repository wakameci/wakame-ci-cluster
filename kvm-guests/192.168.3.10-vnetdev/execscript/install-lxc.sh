#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
centos_ver=6.5

chroot $1 /bin/bash -ex <<'EOS'
  yum install --disablerepo=updates -y lxc lxc-libs lxc-templates bridge-utils rsync
EOS

chroot $1 /bin/bash -ex <<EOS
  lxc-create -t centos -n lxc1 -- -R ${centos_ver}
  echo root:root | sudo chroot /var/lib/lxc/lxc1/rootfs chpasswd
EOS

echo 'lxc.network.hwaddr = 00:18:51:e5:35:01' >> $1/var/lib/lxc/lxc1/config
echo 'lxc.network.veth.pair = veth_kvm1lxc1'  >> $1/var/lib/lxc/lxc1/config
sed -i -e 's/^\(lxc.network.link\)/#\1/'         $1/var/lib/lxc/lxc1/config
