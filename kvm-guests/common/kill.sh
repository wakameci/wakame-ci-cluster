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
kill_remove_pidfile ${pidfile}
