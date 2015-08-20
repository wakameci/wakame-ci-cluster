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
set -u
set -x

PATH=/bin:/usr/bin:/sbin:/usr/sbin

ctid="${1:-""}"
if [[ -z "${ctid}" ]]; then
  echo "${0} <ctid>" >&2
  exit 1
fi

state="$(lxc-info -n "${ctid}" | egrep ^State: | awk '{print $2}')"

if ! [[ "${state}" == "STOPPED" ]]; then
  echo "State is not STOPPED: ${state}" >&2
  exit 1
fi

if [[ -d "/var/lib/lxc/${ctid}" ]]; then
  rm -rf "/var/lib/lxc/${ctid}"
fi
