#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

[[ -f ./metadata/vmspec.conf ]]
.     ./metadata/vmspec.conf

#
pidfile=kvm.pid
monitor_addr=127.0.0.1
monitor_port=$((14000 + ${offset}))

function shutdown_remove_pidfile() {
  local pidfile=${1} monitor_addr=${2} monitor_port=${3}
  [[ -f ${pidfile} ]] || return 0

  local pid=$(head -1 ${pidfile})
  if ps -p ${pid}; then
    echo system_powerdown | nc ${monitor_addr} ${monitor_port}

    while ps -p ${pid}; do
      sleep 1
    done
  fi

  rm -f ${pidfile}
  sync
}

shutdown_remove_pidfile ${pidfile} ${monitor_addr} ${monitor_port}
