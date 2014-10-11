#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

chroot $1 /bin/bash -ex <<'EOS'
  chkconfig --list jenkins
  chkconfig jenkins on
  chkconfig --list jenkins
EOS
