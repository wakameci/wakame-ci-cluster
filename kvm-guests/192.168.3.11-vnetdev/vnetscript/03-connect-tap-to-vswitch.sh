#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

VETH1="veth_kvm2lxc1"
VETH2="veth_kvm2lxc2"

sudo ovs-vsctl add-port br0 ${VETH1}
sudo ovs-vsctl add-port br0 ${VETH2}
sudo ovs-vsctl show
