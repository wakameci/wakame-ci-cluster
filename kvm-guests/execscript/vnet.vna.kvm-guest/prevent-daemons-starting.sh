#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

chroot $1 $SHELL -ex <<'EOS'
  chkconfig iptables off
  chkconfig ip6tables off
EOS
