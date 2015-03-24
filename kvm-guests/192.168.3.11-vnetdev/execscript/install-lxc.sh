#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
centos_ver=6.6
kvm_suffix=2
lxc_count=2
mac_start=3

. ../common/lxc-init.sh ${chroot_dir} ${centos_ver} ${kvm_suffix} ${lxc_count} ${mac_start}

