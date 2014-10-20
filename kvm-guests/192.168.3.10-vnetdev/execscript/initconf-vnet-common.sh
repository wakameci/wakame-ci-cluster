#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
ipaddr=10.0.1.10

cat > $1/etc/openvnet/common.conf <<EOS
registry {
  adapter "redis"
  host "${ipaddr}"
  port 6379
}

db {
  adapter "mysql2"
  host "localhost"
  database "vnet"
  port 3306
  user "root"
  password ""
}
EOS
