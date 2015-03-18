#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' ${chroot_dir}/etc/sysctl.conf
