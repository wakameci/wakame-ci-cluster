#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

box_path=../../boxes/kemukins-6.5-x86_64.kvm.box

sudo /bin/bash -e <<EOS
  ../common/stop.sh

  time tar zxvf ${box_path}
  time sync

  ../common/kemukins-init.sh
  ../common/qcow2-init.sh
  ./run.sh
EOS
