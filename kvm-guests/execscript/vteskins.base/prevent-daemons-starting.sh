#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

chroot $1 $SHELL -ex <<'EOS'
  chkconfig auditd off
  chkconfig postfix off
EOS

rm -f ${chroot_dir}/etc/sysconfig/iptables
