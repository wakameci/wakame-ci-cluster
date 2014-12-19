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
function qemu_kvm_path() {
  local execs="/usr/libexec/qemu-kvm /usr/bin/kvm /usr/bin/qemu-kvm"

  local command_path exe
  for exe in ${execs}; do
    [[ -x "${exe}" ]] && command_path=${exe} || :
  done

  [[ -n "${command_path}" ]] || { echo "[ERROR] command not found: ${execs} (${BASH_SOURCE[0]##*/}:${LINENO})." >&2; return 1; }
  echo ${command_path}
}

#
kill_remove_pidfile ${pidfile}

#
$(qemu_kvm_path) -name ${name} \
 -cpu ${cpu_type} \
 -m ${mem_size} \
 -smp ${cpu_num} \
 -vnc ${vnc_addr}:${vnc_port} \
 -k en-us \
 -rtc ${rtc} \
 -monitor telnet:127.0.0.1:${monitor_port},server,nowait \
 -serial telnet:${serial_addr}:${serial_port},server,nowait \
 -serial ${console} \
 -drive file=./box-disk1-head.qcow2,media=disk,boot=on,index=0,cache=none,if=${drive_type} \
 $([[ -f ./box-disk2.raw ]] && echo -drive file=./box-disk2.raw,media=disk,boot=off,index=1,cache=none,if=${drive_type}) \
 $(
 i=0
 for brname in ${brnames[@]}; do
   echo -netdev tap,ifname=${name}-${monitor_port}-${i},id=hostnet${i},script=,downscript=
   echo -device ${nic_driver},netdev=hostnet${i},mac=${macs[${i}]},bus=pci.0,addr=0x$((3 + ${i}))
   i=$((${i} + 1))
 done
 ) \
 -chardev socket,port=${qmp_port},host=${qmp_addr},server,nowait,id=qga0 \
 -device virtio-serial \
 -device virtserialport,chardev=qga0,name=org.qemu.guest_agent.0 \
 -pidfile ${pidfile} \
 -incoming "exec: cat $(pwd)/kvm.state" \
 -daemonize

#
i=0
for brname in ${brnames[@]}; do
  ip link set ${name}-${monitor_port}-${i} up
  brctl addif ${brnames[${i}]} ${name}-${monitor_port}-${i}
  i=$((${i} + 1))
done
