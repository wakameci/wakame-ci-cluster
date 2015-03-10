#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
centos_ver=6.6

chroot $1 /bin/bash -ex <<EOS
  lxc-create -t centos -n lxc1 -- -R ${centos_ver}
  echo root:root | sudo chroot /var/lib/lxc/lxc1/rootfs chpasswd
  lxc-create -t centos -n lxc2 -- -R ${centos_ver}
  echo root:root | sudo chroot /var/lib/lxc/lxc2/rootfs chpasswd
  wget http://dl.fedoraproject.org/pub/epel/6/x86_64/iperf3-3.0.10-1.el6.x86_64.rpm
  rpm -i --root=/var/lib/lxc/lxc1/rootfs --nodeps iperf3-3.0.10-1.el6.x86_64.rpm
  rpm -i --root=/var/lib/lxc/lxc2/rootfs --nodeps iperf3-3.0.10-1.el6.x86_64.rpm
EOS

cat > $1/var/lib/lxc/lxc1/config <<'EOS'
lxc.network.type = veth
lxc.network.flags = up
#lxc.network.link = virbr0
lxc.rootfs = /var/lib/lxc/lxc1/rootfs
lxc.include = /usr/share/lxc/config/centos.common.conf
lxc.arch = x86_64
lxc.utsname = lxc1
lxc.autodev = 0
lxc.network.name = eth0
lxc.network.hwaddr = 00:18:51:e5:35:01
lxc.network.veth.pair = veth_kvm1lxc1
EOS

cat > $1/var/lib/lxc/lxc2/config <<'EOS'
lxc.network.type = veth
lxc.network.flags = up
#lxc.network.link = virbr0
lxc.rootfs = /var/lib/lxc/lxc2/rootfs
lxc.include = /usr/share/lxc/config/centos.common.conf
lxc.arch = x86_64
lxc.utsname = lxc2
lxc.autodev = 0
lxc.network.name = eth0
lxc.network.hwaddr = 00:18:51:e5:35:02
lxc.network.veth.pair = veth_kvm1lxc2
EOS
