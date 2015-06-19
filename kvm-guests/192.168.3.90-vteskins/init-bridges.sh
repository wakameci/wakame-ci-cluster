#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

ip_mng_br0=192.168.3.1
net_mng_br0=192.168.3.0
name_ovs_br0=vnet-itest-0
name_ovs_br1=vnet-itest-1
name_ovs_br2=vnet-itest-2
name_ovs_br3=vnet-itest-3
name_mng_br0=vnet-br0

sudo ip link set ${name_ovs_br0} down || true
sudo brctl delbr ${name_ovs_br0} || true
sudo brctl addbr ${name_ovs_br0}
sudo ip link set ${name_ovs_br0} up

sudo ip link set ${name_ovs_br1} down || true
sudo brctl delbr ${name_ovs_br1} || true
sudo brctl addbr ${name_ovs_br1}
sudo ip link set ${name_ovs_br1} up

sudo ip link set ${name_ovs_br2} down || true
sudo brctl delbr ${name_ovs_br2} || true
sudo brctl addbr ${name_ovs_br2}
sudo ip link set ${name_ovs_br2} up

sudo ip link set ${name_ovs_br3} down || true
sudo brctl delbr ${name_ovs_br3} || true
sudo brctl addbr ${name_ovs_br3}
sudo ip link set ${name_ovs_br3} up

sudo ip link set ${name_mng_br0} down || true
sudo brctl delbr ${name_mng_br0} || true
sudo brctl addbr ${name_mng_br0}
sudo ifconfig ${name_mng_br0} ${ip_mng_br0} up

sudo route add -net ${net_mng_br0} netmask 255.255.255.0 gw ${ip_mng_br0} ${name_mng_br0}
