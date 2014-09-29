#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

[[ -f box-disk1.raw ]]
[[ $UID == 0 ]]

[[ -f ./metadata/vmspec.conf ]]
.     ./metadata/vmspec.conf

.     ../common/qemu-kvm.conf

#
vnc_addr=127.0.0.1
vnc_port=$((11000 + ${offset}))
monitor_addr=127.0.0.1
monitor_port=$((14000 + ${offset}))
serial_addr=127.0.0.1
serial_port=$((15000 + ${offset}))
drive_type=virtio
nic_driver=virtio-net-pci
rtc="base=utc"

#
kill_remove_pidfile
$(qemu_kvm_path) -name ${name} \
 -cpu ${cpu_type} \
 -m ${mem_size} \
 -smp ${cpu_num} \
 -vnc ${vnc_addr}:${vnc_port} \
 -k en-us \
 -rtc ${rtc} \
 -monitor telnet:127.0.0.1:${monitor_port},server,nowait \
 -serial telnet:${serial_addr}:${serial_port},server,nowait \
 -drive file=./box-disk1.raw,media=disk,boot=on,index=0,cache=none,if=virtio \
 $([[ -f ./box-disk2.raw ]] && echo -drive file=./box-disk2.raw,media=disk,boot=off,index=1,cache=none,if=virtio ) \
 -netdev tap,ifname=${name}-${monitor_port},id=hostnet0,script=,downscript= \
 -device ${nic_driver},netdev=hostnet0,mac=52:54:00:$(date +%H:%M:%S),bus=pci.0,addr=0x3 \
 -daemonize

ip link set ${name}-${monitor_port} up
brctl addif ${brname} ${name}-${monitor_port}
