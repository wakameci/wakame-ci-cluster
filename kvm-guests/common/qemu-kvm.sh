function kill_remove_pidfile() {
  local pidfile=${1}
  [[ -f ${pidfile} ]] || return 0

  local pid=$(head -1 ${pidfile})
  if ps -p ${pid}; then
    kill -TERM ${pid} || kill -KILL ${pid}
  fi

  rm -f ${pidfile}
  sleep 3
}
