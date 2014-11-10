#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

function render_lxc_conf() {
  local ctid=${1:-101}

  cat <<EOS
lxc.utsname = ct${ctid}.$(hostname)
lxc.tty = 6
#lxc.pts = 1024
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = lxcbr0
lxc.network.name = eth0
lxc.network.mtu = 1472
lxc.network.hwaddr = 52:54:00:$(LANG=C LC_ALL=C date +%H:%M:%S)
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
  local ctid=${1:-101}
  local lxc_conf_path=/etc/lxc/${ctid}.conf

  render_lxc_conf  ${ctid} > ${lxc_conf_path}
  chmod 644 ${lxc_conf_path}
}

function render_ifcfg() {
  local ctid=${1:-101}

  cat <<EOS
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
BROADCAST=172.16.254.255
GATEWAY=172.16.254.1
IPADDR=172.16.254.${ctid}
NETMASK=255.255.255.0
MTU=1472
EOS
}

function install_ifcfg() {
  local ctid=${1:-101}
  local ifcfg_path=/lxc/private/${ctid}/etc/sysconfig/network-scripts/ifcfg-eth0

  render_ifcfg ${ctid} > ${ifcfg_path}
  chmod 644 ${ifcfg_path}
}


## main

declare ctid=${1:-101}

mkdir -p /lxc/private/${ctid}
tar zpxf /lxc/template/cache/vz.kemukins.x86_64.tar.gz -C /lxc/private/${ctid}/
sed -i s,^HOSTNAME=.*,HOSTNAME=ct${ctid}.$(hostname), /lxc/private/${ctid}/etc/sysconfig/network

install_lxc_conf ${ctid}
install_ifcfg    ${ctid}

lxc-create -f /etc/lxc/${ctid}.conf -n ${ctid}
lxc-start -n ${ctid} -d -l DEBUG -o /var/log/lxc/${ctid}.log
