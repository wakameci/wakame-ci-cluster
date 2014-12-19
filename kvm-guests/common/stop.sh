#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

[[ $UID == 0 ]]

.     ../common/qemu-kvm.sh

#
kill_remove_pidfile ${pidfile}
