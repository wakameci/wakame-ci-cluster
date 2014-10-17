#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
ipaddr=10.0.1.10

cat > $1/etc/openvnet/vnmgr.conf <<EOS
node {
  id "vnmgr"
  addr {
    protocol "tcp"
    host "${ipaddr}"
    port 9102
  }
  plugins [:vdc_vnet_plugin]
}
EOS

cat > $1/etc/openvnet/webapi.conf <<EOS
node {
  id "webapi"
  addr {
    protocol "tcp"
    host "${ipaddr}"
    port 9101
  }
}
EOS
