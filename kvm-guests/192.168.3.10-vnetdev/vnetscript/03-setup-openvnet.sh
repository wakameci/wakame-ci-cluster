#!/bin/bash
#
# requires:
#  bash
#
set -u
set -e
set -o pipefail

# Config
VETH1="veth_kvm1lxc1"
VETH2="veth_kvm1lxc2"
ETH="eth0"

DP_UUID1="dp-kvm1lxc1"
DP_NAME1=${DP_UUID1}
DP_NODEID1="vna1"
DP_DPID1="0x0000aaaaaaaaaaaa"
DP_UUID2="dp-kvm1lxc2"
DP_NAME2=${DP_UUID2}
DP_NODEID2="vna2"
DP_DPID2="0x0000bbbbbbbbbbbb"

NW_PUB_UUID="nw-public"
NW_PUB_NAME=${NW_PUB_UUID}
NW_PUB_NETWORK="192.168.3.0"
NW_PUB_PREFIX="24"
NW_PUB_MODE="physical"

NW_KVM_UUID="nw-kvm1"
NW_KVM_NAME=${NW_KVM_UUID}
NW_KVM_NETWORK="10.0.0.0"
NW_KVM_PREFIX="24"
NW_KVM_MODE="virtual"

IF_K1L1_UUID="if-kvm1lxc1"
IF_K1L1_MAC="00:18:51:e5:35:01"
IF_K1L1_ADDR="10.0.0.200"
IF_K1L2_UUID="if-kvm1lxc2"
IF_K1L2_MAC="00:18:51:e5:35:02"
IF_K1L2_ADDR="10.0.0.201"

IF_PUB_UUID1="if-public1"
IF_PUB_MAC1="52:54:00:51:06:47"
IF_PUB_ADDR1="192.168.3.10"
IF_PUB_UUID2="if-public2"
IF_PUB_MAC2="52:54:00:51:06:48"
IF_PUB_ADDR2="192.168.3.11"

DN_KVM1_BMAC="00:18:51:e5:33:01"
#DN_KVM2_BMAC="00:18:51:e5:33:02"
DN_PUB_BMAC1="00:18:51:e5:33:05"
#DN_PUB_BMAC2="00:18:51:e5:33:06"

DH_UUID1="if-dhcp1"
DH_NAME1=${DH_UUID1}
DH_MAC1="02:00:00:00:01:01"
DH_ADDR1="10.0.0.2"
DH_UUID2="if-dhcp2"
DH_NAME2=${DH_UUID2}
DH_MAC2="02:00:00:00:01:02"
DH_ADDR2="10.0.0.3"

# For bundler?
cd /opt/axsh/openvnet/vnctl/

# Datapaths
vnctl datapaths add --uuid ${DP_UUID1} --display-name ${DP_NAME1} --node-id ${DP_NODEID1} --dpid ${DP_DPID1}
vnctl datapaths add --uuid ${DP_UUID2} --display-name ${DP_NAME2} --node-id ${DP_NODEID2} --dpid ${DP_DPID2}

# Networks
vnctl networks add --uuid ${NW_PUB_UUID} --display-name ${NW_PUB_NAME} --ipv4-network ${NW_PUB_NETWORK} --ipv4-prefix ${NW_PUB_PREFIX} --network-mode ${NW_PUB_MODE}
vnctl networks add --uuid ${NW_KVM_UUID} --display-name ${NW_KVM_NAME} --ipv4-network ${NW_KVM_NETWORK} --ipv4-prefix ${NW_KVM_PREFIX} --network-mode ${NW_KVM_MODE}

# VM interfaces (LXC)
vnctl interfaces add --uuid ${IF_K1L1_UUID} --mac-address ${IF_K1L1_MAC} --network-uuid ${NW_KVM_UUID} --ipv4-address ${IF_K1L1_ADDR} --port-name ${VETH1}
vnctl interfaces add --uuid ${IF_K1L2_UUID} --mac-address ${IF_K1L2_MAC} --network-uuid ${NW_KVM_UUID} --ipv4-address ${IF_K1L2_ADDR} --port-name ${VETH2}

# Public
vnctl interfaces add --uuid ${IF_PUB_UUID1} --owner-datapath-uuid ${DP_UUID1} --mac-address ${IF_PUB_MAC1} --network-uuid ${NW_PUB_UUID} --ipv4-address ${IF_PUB_ADDR1} --port-name ${ETH} --mode host
vnctl interfaces add --uuid ${IF_PUB_UUID2} --owner-datapath-uuid ${DP_UUID2} --mac-address ${IF_PUB_MAC2} --network-uuid ${NW_PUB_UUID} --ipv4-address ${IF_PUB_ADDR2} --port-name ${ETH} --mode host

# Datapath networks
vnctl datapaths networks add ${DP_UUID1} ${NW_KVM_UUID} --broadcast-mac-address ${DN_KVM1_BMAC} --interface-uuid ${IF_PUB_UUID1}
#vnctl datapaths networks add ${DP_UUID2} ${NW_KVM_UUID} --broadcast-mac-address ${DN_KVM2_BMAC} --interface-uuid ${IF_PUB_UUID2}
vnctl datapaths networks add ${DP_UUID1} ${NW_PUB_UUID} --broadcast-mac-address ${DN_PUB_BMAC1} --interface-uuid ${IF_PUB_UUID1}
#vnctl datapaths networks add ${DP_UUID2} ${NW_PUB_UUID} --broadcast-mac-address ${DN_PUB_BMAC2} --interface-uuid ${IF_PUB_UUID2}

# DHCP
vnctl interfaces add --uuid ${DH_UUID1} --mac-address ${DH_MAC1} --network-uuid ${NW_KVM_UUID} --ipv4-address ${DH_ADDR1} --mode simulated
vnctl interfaces add --uuid ${DH_UUID2} --mac-address ${DH_MAC2} --network-uuid ${NW_KVM_UUID} --ipv4-address ${DH_ADDR2} --mode simulated
vnctl network-services add --interface-uuid ${DH_UUID1} --display-name ${DH_NAME1} --type "dhcp"
vnctl network-services add --interface-uuid ${DH_UUID2} --display-name ${DH_NAME2} --type "dhcp"
