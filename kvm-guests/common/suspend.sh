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

nc ${monitor_addr} ${monitor_port} <<-EOS
	migrate_set_speed 1g
	stop
	migrate "exec: cat > $(pwd)/kvm.state"
	EOS

while ! nc ${monitor_addr} ${monitor_port} <<< "info migrate" | egrep "^Migration status: completed"; do
  sleep 1
done

nc ${monitor_addr} ${monitor_port} <<-EOS
	quit
	EOS
