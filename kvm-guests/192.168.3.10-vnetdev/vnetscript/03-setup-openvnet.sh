#!/bin/bash
#
# requires:
#  bash
#
set -u
set -e
set -o pipefail

# Config
VETH="veth_kvm1lxc1"
ETH="eth0"

DP_UUID="dp-kvm1lxc1"
DP_NAME=${DP_UUID}
DP_NODEID="vna"
DP_DPID="0x0000aaaaaaaaaaaa"

NW_PUB_UUID="nw-public"
NW_PUB_NAME=${NW_PUB_UUID}
NW_PUB_NETWORK="192.168.3.0"
NW_PUB_PREFIX="24"
NW_PUB_MODE="physical"

NW_KVM1_UUID="nw-kvm1"
NW_KVM1_NAME=${NW_KVM1_UUID}
NW_KVM1_NETWORK="10.0.0.0"
NW_KVM1_PREFIX="24"
NW_KVM1_MODE="virtual"

IF_K1L1_UUID="if-kvm1lxc1"
IF_K1L1_MAC="00:18:51:e5:35:01"
IF_K1L1_ADDR="10.0.0.200"

IF_PUB_UUID="if-public"
IF_PUB_MAC="52:54:00:51:06:47"
IF_PUB_ADDR="192.168.3.10"

DN_KVM1_BMAC="00:18:51:e5:33:01"
DN_PUB_BMAC="00:18:51:e5:33:05"

DH_UUID="if-dhcp1"
DH_NAME=${DH_UUID}
DH_MAC="02:00:00:00:01:01"
DH_ADDR="10.0.0.2"

# For bundler?
cd /opt/axsh/openvnet/vnctl/

# Datapaths
vnctl datapaths add --uuid ${DP_UUID} --display-name ${DP_NAME} --node-id ${DP_NODEID} --dpid ${DP_DPID}

# Networks
vnctl networks add --uuid ${NW_PUB_UUID} --display-name ${NW_PUB_NAME} --ipv4-network ${NW_PUB_NETWORK} --ipv4-prefix ${NW_PUB_PREFIX} --network-mode ${NW_PUB_MODE}
vnctl networks add --uuid ${NW_KVM1_UUID} --display-name vnet1 --ipv4-network ${NW_KVM1_NETWORK} --ipv4-prefix ${NW_KVM1_PREFIX} --network-mode ${NW_KVM1_MODE}

# VM interfaces (LXC)
vnctl interfaces add --uuid ${IF_K1L1_UUID} --mac-address ${IF_K1L1_MAC} --network-uuid ${NW_KVM1_UUID} --ipv4-address ${IF_K1L1_ADDR} --port-name ${VETH}

# Public
vnctl interfaces add --uuid ${IF_PUB_UUID} --owner-datapath-uuid ${DP_UUID} --mac-address ${IF_PUB_MAC} --network-uuid ${NW_PUB_UUID} --ipv4-address ${IF_PUB_ADDR} --port-name ${ETH} --mode host

# Datapath networks
vnctl datapaths networks add ${DP_UUID} ${NW_KVM1_UUID} --broadcast-mac-address ${DN_KVM1_BMAC} --interface-uuid ${IF_PUB_UUID}
vnctl datapaths networks add ${DP_UUID} ${NW_PUB_UUID} --broadcast-mac-address ${DN_PUB_BMAC} --interface-uuid ${IF_PUB_UUID}

# DHCP
vnctl interfaces add --uuid ${DH_UUID} --mac-address ${DH_MAC} --network-uuid ${NW_KVM1_UUID} --ipv4-address ${DH_ADDR} --mode simulated
vnctl network-services add --interface-uuid ${DH_UUID} --display-name ${DH_NAME} --type "dhcp"
