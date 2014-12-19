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
$(qemu_command) -incoming "exec: cat $(pwd)/kvm.state"
attach_vif_to_bridge
