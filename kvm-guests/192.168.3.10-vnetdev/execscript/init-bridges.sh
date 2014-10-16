#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
ip_vnet_ovs_br0=10.0.0.1
ip_vnet_mng_br0=10.0.1.1

sudo ifconfig    vnet_ovs_br0 down
sudo brctl delbr vnet_ovs_br0 || true
sudo brctl addbr vnet_ovs_br0
sudo ifconfig    vnet_ovs_br0 ${ip_vnet_ovs_br0} up

sudo ifconfig    vnet_mng_br0 down
sudo brctl delbr vnet_mng_br0 || true
sudo brctl addbr vnet_mng_br0
sudo ifconfig    vnet_mng_br0 ${ip_vnet_mng_br0} up
