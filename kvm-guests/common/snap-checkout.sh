#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

current=${1:-1}
index=$(printf "%04d" ${current})

serial=$(date +%s)

sudo bash -ex <<EOS
  ../common/stop.sh

  [[ -f kvm.state ]] && \
  mv -i kvm.state _kvm_${serial}.state
  cp -i kvm_${index}.state kvm.state

  [[ -f box-disk1-head.qcow2 ]] && \
  mv -i box-disk1-head.qcow2 _box-disk1_${serial}.qcow2
  cp -i box-disk1_${index}.qcow2 box-disk1-head.qcow2

  ../common/resume.sh
EOS
