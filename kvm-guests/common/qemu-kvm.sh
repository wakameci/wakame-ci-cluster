# -*-Shell-script-*-
#
# requires:
#  bash
#

#
vnc_addr=127.0.0.1
vnc_port=$((11000 + ${offset}))
monitor_addr=127.0.0.1
monitor_port=$((14000 + ${offset}))
serial_addr=127.0.0.1
serial_port=$((15000 + ${offset}))
console=${console:-file:console.log}
qmp_addr=127.0.0.1
qmp_port=$((16000 + ${offset}))
drive_type=${drive_type:-virtio}
nic_driver=${nic_driver:-virtio-net-pci}
pidfile=kvm.pid
rtc=${rtc:-"base=utc"}

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
function kill_remove_pidfile() {
  local pidfile=${1}
  [[ -f ${pidfile} ]] || return 0

  local pid=$(head -1 ${pidfile})
  while ps -p ${pid}; do
    kill -TERM ${pid} || kill -KILL ${pid}
    sleep 1
  done

  rm -f ${pidfile}
}
