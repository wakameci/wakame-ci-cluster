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

#
vnc_addr=127.0.0.1
vnc_port=$((11000 + ${offset}))
monitor_addr=127.0.0.1
monitor_port=$((14000 + ${offset}))
serial_addr=127.0.0.1
serial_port=$((15000 + ${offset}))
drive_type=virtio
nic_driver=virtio-net-pci
pidfile=kvm.pid
rtc="base=utc"

#
function qemu_kvm_path() {
  local execs="/usr/libexec/qemu-kvm /usr/bin/kvm /usr/bin/qemu-kvm"

  local command_path exe
  for exe in ${execs}; do
    [[ -x "${exe}" ]] && command_path=${exe} || :
  done

  [[ -n "${command_path}" ]] || { echo "[ERROR] command not found: ${execs} (${BASH_SOURCE[0]##*/}:${LINENO})." >&2; return 1; }
  echo ${command_path}
}

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
 $([[ -f ./box-disk2.raw ]] && echo -drive file=./box-disk2.raw,media=disk,boot=off,index=1,cache=none,if=virtio) \
 $(
 i=0
 for brname in ${brnames[@]}; do
   echo -netdev tap,ifname=${name}-${monitor_port}-${i},id=hostnet${i},script=,downscript=
   echo -device ${nic_driver},netdev=hostnet${i},mac=52:54:00:${RANDOM:0:2}:${RANDOM:0:2}:${RANDOM:0:2},bus=pci.0,addr=0x$((3 + ${i}))
   i=$((${i} + 1))
 done
 ) \
 -pidfile ${pidfile} \
 -daemonize

i=0
for brname in ${brnames[@]}; do
  ip link set ${name}-${monitor_port}-${i} up
  brctl addif ${brnames[${i}]} ${name}-${monitor_port}-${i}
  i=$((${i} + 1))
done
