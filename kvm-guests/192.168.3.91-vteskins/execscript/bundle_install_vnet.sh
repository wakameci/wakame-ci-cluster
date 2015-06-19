#!/bin/bash

set -e
set -o pipefail

chroot_dir=${1}

chroot $1 /bin/bash -ex <<'EOS'
  yum -y install gcc gcc-c++ autoconf openvnet-ruby mysql-devel sqlite-devel

  cd /opt/axsh/openvnet/vnet;             bundle install --path vendor/bundle
  cd /opt/axsh/openvnet/integration_test; bundle install --path vendor/bundle
EOS
