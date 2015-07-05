#!/bin/bash
#
# requires:
#  bash
#

### start container

"${BASH_SOURCE[0]%/*}/lxc-start.sh" "${ctid}"

# setup kvm-host
lxc-attach -n ${ctid} -- bash -ex <<EOS
  cd /tmp
  until curl -fsSkL https://raw.githubusercontent.com/wakameci/wakame-ci-cluster/master/kvm-hosts/setup-${distro_name}-${distro_ver}.sh -o ./setup-${distro_name}-${distro_ver}.sh; do
    sleep 1
  done
  chmod +x ./setup-${distro_name}-${distro_ver}.sh
  sed -i s,--disablerepo=updates,, ./setup-${distro_name}-${distro_ver}.sh
  ls -l ./setup-${distro_name}-${distro_ver}.sh
  ./setup-${distro_name}-${distro_ver}.sh
  rm ./setup-${distro_name}-${distro_ver}.sh
EOS

# warm up device-mapper
"${BASH_SOURCE[0]%/*}/lxc-dmwarmup.sh" "${ctid}"

# setup bridge interface
lxc-attach -n "${ctid}" -- < "${BASH_SOURCE[0]%/*}/setup-kol-pair.sh"
lxc-attach -n "${ctid}" -- service network  restart
lxc-attach -n "${ctid}" -- service iptables restart
