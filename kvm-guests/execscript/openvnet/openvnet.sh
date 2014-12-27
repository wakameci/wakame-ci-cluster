#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

chroot $1 /bin/bash -ex <<'EOS'
  releasever=$(< /etc/yum/vars/releasever)
  case ${releasever} in
    # xxx HOTFIX: Open vSwitch doesn't support CentOS 6.6. xxx
    6.6)
      releasever=6.5
      ;;
  esac
  yum install --disablerepo=updates -y http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/${releasever}/kmod-openvswitch-2.3.0-1.el6.x86_64.rpm
  yum install --disablerepo=updates -y http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/${releasever}/openvswitch-2.3.0-1.x86_64.rpm
EOS

chroot $1 /bin/bash -ex <<'EOS'
  yum install --disablerepo=updates -y openvnet
EOS
