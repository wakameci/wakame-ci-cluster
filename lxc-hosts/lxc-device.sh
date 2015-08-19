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

### add device

lxc-attach -n ${ctid} -- bash -ex <<-EOS
  [[ -c /dev/kvm     ]] || {
    mknod -m 666 /dev/kvm     c 10 232
  }
  [[ -c /dev/net/tun ]] || {
    mkdir -p     /dev/net
    mknod -m 666 /dev/net/tun c 10 200
  }
  [[ -c /dev/vboxnetctl ]] || {
    mknod -m 600 /dev/vboxnetctl c 10 56
  }
  [[ -c /dev/vboxdrvu ]] || {
    mknod -m 666 /dev/vboxdrvu   c 10 57
  }
  [[ -c /dev/vboxdrv ]] || {
    mknod -m 600 /dev/vboxdrv    c 10 58
  }
EOS

# > PTY allocation request failed on channel 0
lxc-attach -n ${ctid} -- bash -ex <<-EOS
  [[ -c /dev/ptmx ]] || mknod -m 666 /dev/ptmx c 5 2
EOS

# /dev/loopX and /dev/dm-X
for i in {0..127}; do
lxc-attach -n ${ctid} -- bash -ex <<-EOS
  [[ -b /dev/loop${i} ]] || mknod /dev/loop${i} -m 660 b   7 ${i}
  [[ -b /dev/dm-${i}  ]] || mknod /dev/dm-${i}  -m 660 b 253 ${i}
EOS
done
