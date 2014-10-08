#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

VETH="veth_kvm1lxc1"

sudo ovs-vsctl add-port br0 ${VETH}
sudo ovs-vsctl show
