#!/bin/bash
#
# requires:
#  bash
#
# usage:
#  $0 CTID (192.168.2.CTID)
#
set -e
set -o pipefail
set -x

PATH=/bin:/usr/bin:/sbin:/usr/sbin

function render_lxc_conf() {
  local ctid=${1:-101}

  cat <<EOS
lxc.utsname = ${hostname}
lxc.tty = 6
#lxc.pts = 1024
lxc.network.type = veth
lxc.network.flags = up
#lxc.network.link = lxcbr0
lxc.network.link = kemumakikol0
lxc.network.name = eth0
#lxc.network.mtu = 1472
#lxc.network.hwaddr = 52:54:00:$(LANG=C LC_ALL=C date +%H:%M:%S)
lxc.rootfs = ${rootfs_path}
lxc.rootfs.mount = ${rootfs_path}

# via https://lists.linuxcontainers.org/pipermail/lxc-users/2014-October/007907.html
# [lxc-users] systemd's journald using 100% CPU on Debian Jessie container and Fedora 20 host
lxc.kmsg = 0

lxc.mount.entry = proc   ${rootfs_path}/proc                   proc    defaults        0 0
lxc.mount.entry = sysfs  ${rootfs_path}/sys                    sysfs   defaults        0 0
lxc.mount.entry = devpts ${rootfs_path}/dev/pts                devpts  gid=5,mode=620  0 0

# lxc.mount.entry = /data     /var/lib/lxc/${ctid}/rootfs/data   none    rw,bind         0 0
# lxc.mount.entry = /dev/sdX  /var/lib/lxc/${ctid}/rootfs/data   ext4    defaults        0 0
# lxc.mount.entry = /dev/sdX  /var/lib/lxc/${ctid}/rootfs/var/lib/jenkins/workspace   ext4    defaults        0 0

# via http://www.janoszen.com/2013/05/14/lxc-tutorial/
# > Allow any mknod (but not using the node)
# one of usage is for /dev/loopX
lxc.cgroup.devices.allow = c *:* m
lxc.cgroup.devices.allow = b *:* m

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

# kvm
lxc.cgroup.devices.allow = c 232:10 rwm

# net/tun
lxc.cgroup.devices.allow = c 10:200 rwm

# nbd
lxc.cgroup.devices.allow = c 43:* rwm

# fuse
lxc.cgroup.devices.allow = c 10:229 rwm

# hpet
lxc.cgroup.devices.allow = c 10:228 rwm

# control device-mapper
# via https://lists.linuxcontainers.org/pipermail/lxc-users/2014-January/006077.html
lxc.cgroup.devices.allow = c 10:236 rwm
lxc.cgroup.devices.allow = b 252:* rwm
# dm-X control/loopXpX
lxc.cgroup.devices.allow = b 253:* rwm
EOS
}

function install_lxc_conf() {
  local ctid=${1:-101}
  local lxc_conf_path=/var/lib/lxc/${ctid}/config

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
BROADCAST=192.168.2.255
GATEWAY=192.168.2.1
IPADDR=192.168.2.${ctid}
NETMASK=255.255.255.0
#MTU=1472
EOS
}

function install_ifcfg() {
  local ifcfg_path=${rootfs_path}/etc/sysconfig/network-scripts/ifcfg-eth0

  render_ifcfg ${ctid} > ${ifcfg_path}
  chmod 644 ${ifcfg_path}
}

## main

LANG=C
LC_ALL=C

declare ctid=${1:-101}
declare rootpass=${rootpass:-root}

readonly rootfs_path=/var/lib/lxc/${ctid}/rootfs
readonly hostname=ct${ctid}.$(hostname)
