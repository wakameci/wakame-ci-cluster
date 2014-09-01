#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

ssh_target=jenkins@192.168.2.51

ssh ${ssh_target} <<EOS
  sudo shutdown -h now
EOS

sleep 20
sync

sudo $SHELL -e <<'EOS'
  time tar zxvf ../../boxes/kemukins-6.4-x86_64.kvm.box
  time sync

  ./kemukins-init.sh
  ./run.sh
EOS
