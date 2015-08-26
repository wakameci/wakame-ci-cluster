#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

chroot $1 $SHELL -ex <<'EOS'
  rpm -qi mysql-server >/dev/null || { yum install --disablerepo=updates -y mysql-server; }
EOS

chroot $1 /bin/bash -ex <<'EOS'
  chkconfig mysqld on
EOS
