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

ctid=${1}
if [[ -z "${ctid}" ]]; then
  echo "$0 <ctid>" >&2
  exit 1
fi

### add device

lxc-device -n ${ctid} add /dev/kvm
lxc-device -n ${ctid} add /dev/net/tun

# > PTY allocation request failed on channel 0
lxc-device -n ${ctid} add /dev/ptmx

# /dev/loopX and /dev/dm-X
for i in {0..127}; do
lxc-attach -n ${ctid} -- bash -ex <<-EOS
  [[ -b /dev/loop${i} ]] || mknod /dev/loop${i} -m 660 b   7 ${i}
  [[ -b /dev/dm-${i}  ]] || mknod /dev/dm-${i}  -m 660 b 253 ${i}
EOS
done
