#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

chroot $1 /bin/bash -ex <<'EOS'
  cd /opt/axsh; rm -rf openvnet; mkdir openvnet

  yum -y install nfs-utils

  chkconfig rpcbind on
  chkconfig rpcidmapd on
  chkconfig nfslock on
  chkconfig netfs on

  echo "192.168.3.91:/opt/axsh/openvnet /opt/axsh/openvnet nfs defaults 0 0" >> /etc/fstab
EOS
