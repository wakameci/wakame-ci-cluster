#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
centos_ver=6.6
lxc_count=2

. ../common/lxc-init.sh ${chroot_dir} ${centos_ver} ${lxc_count}

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
