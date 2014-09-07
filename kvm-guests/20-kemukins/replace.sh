#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

target_node=192.168.2.20
ssh_target=jenkins@${target_node}
box_path=../../boxes/vzkemukins-6.5-x86_64.kvm.box

function network_connection?() {
  local ipaddr=${1}
  ping -c 1 -W 3 ${ipaddr}
}

if network_connection? ${target_node}; then
  ssh ${ssh_target} sudo shutdown -h now
  sleep 20
  sync
fi

sudo $SHELL -e <<EOS
  time tar zxvf ${box_path}
  time sync

  ./kemukins-init.sh
  ./run.sh
EOS
