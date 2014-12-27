#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

distro_ver=6.6
[[ -a distro_ver.conf ]] && . distro_ver.conf
box_path=../../boxes/minimal-${distro_ver}-x86_64.kvm.box

sudo /bin/bash -e <<EOS
  ../common/stop.sh

  ../common/unpack-box.sh ${box_path}

  ../common/kemumaki-init.sh
 #./run.sh
  ./pack-box.sh
EOS
