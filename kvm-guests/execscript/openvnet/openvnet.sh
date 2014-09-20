#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

chroot $1 $SHELL -ex <<'EOS'
  releasever=$(< /etc/yum/vars/releasever)

  yum install --disablerepo=updates -y http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/${releasever}/kmod-openvswitch-2.3.0-1.el6.x86_64.rpm
  yum install --disablerepo=updates -y http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/${releasever}/openvswitch-2.3.0-1.x86_64.rpm
EOS

chroot $1 $SHELL -ex <<'EOS'
  until curl -fsSkL -o /etc/yum.repos.d/openvnet.repo https://raw.githubusercontent.com/axsh/openvnet/master/openvnet.repo; do
    sleep 1
  done
  until curl -fsSkL -o /etc/yum.repos.d/openvnet-third-party.repo https://raw.githubusercontent.com/axsh/openvnet/master/openvnet-third-party.repo; do
    sleep 1
  done
EOS

chroot $1 $SHELL -ex <<'EOS'
  yum install --disablerepo=updates -y openvnet
EOS
