#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
centos_ver=6.5

chroot $1 /bin/bash -ex <<'EOS'
  yum install --disablerepo=updates -y lxc lxc-libs lxc-templates bridge-utils libcgroup
EOS

cat > $1/lxc.conf <<'EOS'
lxc.network.type=veth
lxc.network.link=br0
lxc.network.flags=up
EOS

chroot $1 /bin/bash -ex <<EOS
  lxc-create -f /lxc.conf -t centos -n lxc1 -- -R ${centos_ver}
EOS
