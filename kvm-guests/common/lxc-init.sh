#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
centos_ver=${2}
kvm_suffix=${3}
lxc_count=${4}
mac_start=${5}
declare -a tools=("tcpdump" "nc" "strace")

COUNTER=0
while [  $COUNTER -lt ${lxc_count} ]; do
  let COUNTER=COUNTER+1    
  chroot ${chroot_dir} /bin/bash -ex <<EOS
    lxc-create -t centos -n lxc${COUNTER} -- -R ${centos_ver}
    echo root:root | sudo chroot /var/lib/lxc/lxc${COUNTER}/rootfs chpasswd
EOS
  let mac_hex=$(printf '%02x\n' $mac_start)

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
    lxc.network.veth.pair = veth_kvm${kvm_suffix}lxc${COUNTER}

EOS
  . ../common/lxc/iperf3.sh ${chroot_dir} ${COUNTER}
  . ../common/lxc/common-install.sh ${chroot_dir} ${COUNTER} ${tools}
  let mac_start=mac_start+1
done


