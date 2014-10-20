#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

sudo sed -i 's,^ONBOOT=.*$,ONBOOT=no,' /var/lib/lxc/lxc1/rootfs/etc/sysconfig/network-scripts/ifcfg-eth0
sudo lxc-start -d -n lxc1
sudo sed -i 's,^ONBOOT=.*$,ONBOOT=no,' /var/lib/lxc/lxc2/rootfs/etc/sysconfig/network-scripts/ifcfg-eth0
sudo lxc-start -d -n lxc2

sudo lxc-info -n lxc1
sudo lxc-info -n lxc2
