#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

target_node=192.168.3.10
ssh_target=jenkins@${target_node}

distro_ver=6.5
[[ -a distro_ver.conf ]] && . distro_ver.conf
box_path=../../boxes/kemumaki-${distro_ver}-x86_64.kvm.box

function network_connection?() {
  local ipaddr=${1}
  ping -c 1 -W 3 ${ipaddr}
}

if network_connection? ${target_node}; then
  ssh ${ssh_target} sudo shutdown -h now
  sleep 20
  sync
fi

sudo /bin/bash -e <<EOS
  ../common/stop.sh

  time tar zxvf ${box_path}
  time sync

  ../common/kemumaki-init.sh
  ./run.sh
EOS
