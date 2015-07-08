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

lxc-stop -n "${ctid}"

"${BASH_SOURCE[0]%/*}/check-dm.sh"
