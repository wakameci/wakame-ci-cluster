#!/bin/bash
#
# requires:
#  bash
#
# usage:
#  $0 <ctid>
#
set -e
set -o pipefail
set -x

PATH=/bin:/usr/bin:/sbin:/usr/sbin

ctid=${1}
if [[ -z "${ctid}" ]]; then
  echo "$0 <ctid>" >&2
  exit 1
fi

lxc-start -n ${ctid} -d -l DEBUG -o /var/log/lxc/${ctid}.log
lxc-wait  -n ${ctid} -s RUNNING

###

./lxc-device.sh ${ctid}
