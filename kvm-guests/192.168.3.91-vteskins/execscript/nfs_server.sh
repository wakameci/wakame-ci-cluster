#!/bin/bash

set -e
set -o pipefail

chroot_dir=${1}

chroot $1 /bin/bash -ex <<'EOS'
  yum -y install git nfs-utils

  cd /opt/axsh; rm -rf openvnet; git clone https://github.com/axsh/openvnet.git

  echo "/opt/axsh/openvnet 192.168.3.0/24 (rw,no_root_squash)" >> /etc/exports

  chkconfig rpcbind on
  chkconfig nfslock on
  chkconfig nfs on
EOS
