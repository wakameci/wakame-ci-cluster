#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

[[ -f ./metadata/vmspec.conf ]]
.     ./metadata/vmspec.conf

.     ../common/qemu-kvm.sh

#
shutdown_remove_pidfile ${pidfile} ${monitor_addr} ${monitor_port}
