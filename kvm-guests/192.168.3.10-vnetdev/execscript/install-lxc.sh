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
mac_start=1

. ../common/lxc-init.sh ${chroot_dir} ${centos_ver} ${lxc_count}

COUNTER=0
hex=00
while [  $COUNTER -lt ${lxc_count} ]; do
  let COUNTER=COUNTER+1  
  let mac_hex=$(printf '%x\n' $mac_start)

  cat > ${chroot_dir}/var/lib/lxc/lxc${COUNTER}/config <<EOS
    lxc.network.type = veth
    lxc.network.flags = up
    #lxc.network.link = virbr0
    lxc.rootfs = /var/lib/lxc/lxc${COUNTER}/rootfs
    lxc.include = /usr/share/lxc/config/centos.common.conf
    lxc.arch = x86_64
    lxc.utsname = lxc${COUNTER}
    lxc.autodev = 0
    lxc.network.name = eth0
    lxc.network.hwaddr = 00:18:51:e5:35:${mac_hex}
    lxc.network.veth.pair = veth_kvm1lxc${COUNTER}

EOS
  let mac_start=mac_start+1
done

