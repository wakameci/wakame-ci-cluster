#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

distro_ver=7.0.1406
[[ -a distro_ver.conf ]] && . distro_ver.conf
box_path=../../boxes/lxckemumaki-${distro_ver}-x86_64.kvm.box

sudo /bin/bash -e <<EOS
  ../common/stop.sh

  ../common/unpack-box.sh ${box_path}

  ../common/kemumaki-init.sh
  ../common/qcow2-init.sh
  ./run.sh
EOS
