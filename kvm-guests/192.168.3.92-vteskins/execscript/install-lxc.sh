#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

declare start=3

declare chroot_dir=${1}
[[ ! -z ${chroot_dir} ]]

function render_lxc_conf() {
  local ctid=${1}

  cat <<EOS
lxc.utsname = vm${ctid}.$(hostname)
lxc.tty = 6
#lxc.pts = 1024

# 1st interface
lxc.network.type = veth
lxc.network.flags = up
#lxc.network.link = lxcbr0
lxc.network.name = eth0
lxc.network.mtu = 1472
lxc.network.hwaddr = 02:00:00:00:00:0${ctid}
lxc.network.veth.pair = if-v${ctid}
# 2nd interface
lxc.network.type = veth
lxc.network.flags = up
#lxc.network.link = lxcbr0
lxc.network.name = eth1
lxc.network.mtu = 1472
lxc.network.hwaddr = 02:00:01:00:00:0${ctid}
lxc.network.veth.pair = if-m${ctid}

lxc.rootfs = /lxc/private/${ctid}
lxc.rootfs.mount = /lxc/private/${ctid}

#lxc.mount.entry = devpts /lxc/private/${ctid}/dev/pts                devpts  gid=5,mode=620  0 0
lxc.mount.entry = proc   /lxc/private/${ctid}/proc                   proc    defaults        0 0
lxc.mount.entry = sysfs  /lxc/private/${ctid}/sys                    sysfs   defaults        0 0

# /dev/null and zero
lxc.cgroup.devices.allow = c 1:3 rwm
lxc.cgroup.devices.allow = c 1:5 rwm

# consoles
lxc.cgroup.devices.allow = c 5:1 rwm
lxc.cgroup.devices.allow = c 5:0 rwm
lxc.cgroup.devices.allow = c 4:0 rwm
lxc.cgroup.devices.allow = c 4:1 rwm

# /dev/{,u}random
lxc.cgroup.devices.allow = c 1:9 rwm
lxc.cgroup.devices.allow = c 1:8 rwm
lxc.cgroup.devices.allow = c 136:* rwm
lxc.cgroup.devices.allow = c 5:2 rwm

# rtc
lxc.cgroup.devices.allow = c 254:0 rwm
EOS
}

function install_lxc_conf() {
  local ctid=${1}
  local lxc_conf_path=${chroot_dir}/etc/lxc/${ctid}.conf

  render_lxc_conf  ${ctid} > ${lxc_conf_path}
  chmod 644 ${lxc_conf_path}
}

function render_ifcfg0_dhcp() {
  local ctid=${1}

  cat <<EOS
DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes
TYPE=Ethernet
EOS
}

function render_ifcfg1_static() {
  local ctid=${1}

  cat <<EOS
DEVICE=eth1
BOOTPROTO=static
ONBOOT=yes
TYPE=Ethernet
IPADDR=10.50.0.10${ctid}
NETMASK=255.255.255.0
EOS
}

function install_ifcfg() {
  local ctid=${1}
  local ifcfg0_path=${chroot_dir}/lxc/private/${ctid}/etc/sysconfig/network-scripts/ifcfg-eth0
  local ifcfg1_path=${chroot_dir}/lxc/private/${ctid}/etc/sysconfig/network-scripts/ifcfg-eth1

  render_ifcfg0_dhcp   ${ctid} > ${ifcfg0_path}
  render_ifcfg1_static ${ctid} > ${ifcfg1_path}
  chmod 644 ${ifcfg0_path} ${ifcfg1_path}
}

function render_run_sh() {
  local ctid=${1}

  cat <<EOS
#!/bin/bash
lxc-start -n ${ctid} -d -l DEBUG -o /var/log/lxc/${ctid}.log
# virt
ip link set if-v${ctid} up
ovs-vsctl --if-exists del-port br0 if-v${ctid}
ovs-vsctl add-port br0 if-v${ctid}
# mng
ip link set if-m${ctid} up
ovs-vsctl --if-exists del-port br1 if-m${ctid}
ovs-vsctl add-port br1 if-m${ctid}
EOS
}

function install_lxc() {
  local ctid=${1}

  mkdir -p ${chroot_dir}/lxc/private/${ctid}
  tar zpxf ${chroot_dir}/lxc/template/cache/vz.kemumaki.x86_64.tar.gz -C ${chroot_dir}/lxc/private/${ctid}/
  sed -i s,^HOSTNAME=.*,HOSTNAME=vm${ctid}, ${chroot_dir}/lxc/private/${ctid}/etc/sysconfig/network

  install_lxc_conf ${ctid}
  install_ifcfg    ${ctid}

  chroot ${chroot_dir} /bin/bash -ex <<EOS
    lxc-create -f /etc/lxc/${ctid}.conf -n ${ctid}
EOS

  if [[ -d lxcscript ]]; then
    while read line; do
      eval ${line} ${chroot_dir}/lxc/private/${ctid}
    done < <(find -L lxcscript ! -type d -name '*.sh' | sort)
  fi

  render_run_sh ${ctid} > ${chroot_dir}/lxc/private/${ctid}/run.sh
  chmod 755 ${chroot_dir}/lxc/private/${ctid}/run.sh
}

## main

declare ctid1=`expr "${start}" + 0`
[[ ! -z ${ctid1} ]]
declare ctid2=`expr ${ctid1} + 1`
[[ ${ctid1} != ${ctid2} ]]

install_lxc ${ctid1}
install_lxc ${ctid2}
