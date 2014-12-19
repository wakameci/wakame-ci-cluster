#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

[[ -f box-disk1-head.qcow2 ]]
[[ $UID == 0 ]]

[[ -f ./metadata/vmspec.conf ]]
.     ./metadata/vmspec.conf

.     ../common/qemu-kvm.sh

#
kill_remove_pidfile ${pidfile}

#
eval $(qemu_command) -incoming \"exec: cat $(pwd)/kvm.state\"

#
i=0
for brname in ${brnames[@]}; do
  ip link set ${name}-${monitor_port}-${i} up
  brctl addif ${brnames[${i}]} ${name}-${monitor_port}-${i}
  i=$((${i} + 1))
done
