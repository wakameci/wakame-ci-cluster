#!/bin/bash
#
# requires:
#  bash
#
# description:
#  setup a bridge/ether pair for KVM on LXC environment
#
# usage:
#  $0 <base_if> <bridge_if>
#
set -e
set -o pipefail
set -x

base_if=${1:-em1}
bridge_if=${2:-kemumakikol0}

. /etc/sysconfig/network-scripts/ifcfg-${base_if}

function render_ifcfg_bridge() {
  cat <<EOS
DEVICE=${bridge_if}
TYPE=Bridge
ONBOOT=yes

BOOTPROTO=static

IPADDR="${IPADDR}"
PREFIX="${PREFIX:-"24"}"
GATEWAY="${GATEWAY}"
DNS1="${DNS1:-"8.8.8.8"}"
EOS
}

function install_ifcfg_bridge() {
  render_ifcfg_bridge | tee /etc/sysconfig/network-scripts/ifcfg-${bridge_if}
}

function render_ifcfg_ether() {
  cat <<EOS
DEVICE=${base_if}
BRIDGE=${bridge_if}
BOOTPROTO=none
ONBOOT=yes
EOS
}

function install_ifcfg_ether() {
  render_ifcfg_ether | tee /etc/sysconfig/network-scripts/ifcfg-${base_if}
}

if [[ ${UID} != 0 ]]; then
  echo "Must run as root" >&2
  exit 1
fi

if [[ -f /etc/sysconfig/network-scripts/ifcfg-${bridge_if} ]]; then
  echo already exists: /etc/sysconfig/network-scripts/ifcfg-${bridge_if}. 2>&1
  exit 1
fi
if [[ ! -f /etc/sysconfig/network-scripts/ifcfg-${base_if} ]]; then
  echo does not exist: /etc/sysconfig/network-scripts/ifcfg-${bridge_if}. 2>&1
  exit 1
fi

install_ifcfg_bridge
install_ifcfg_ether

cat <<EOS
You should run "\$ sudo service network restart"
EOS
