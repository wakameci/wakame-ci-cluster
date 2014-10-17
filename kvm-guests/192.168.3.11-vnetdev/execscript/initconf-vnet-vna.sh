#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
ipaddr=10.0.1.11

cat > $1/etc/openvnet/vna.conf <<EOS
node {
  id "vna"
  addr {
    protocol "tcp"
    host "${ipaddr}"
    port 9103
  }
}

network {
  uuid ""
  gateway {
    address ""
  }
}
EOS
