#!/bin/bash

EWW="${EWW:-$DWM/eww}"
WINDOWS=(c_backdrop c_profile c_flclash c_background c_folders c_weather c_search c_quote c_shutdown c_logout c_reboot)

# serialize presses so concurrent invocations cannot spawn extra daemons
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/eww-panel-$(id -u).lock"
flock -n 9 || exit 0

# wait for the autostarted daemon; restart it if it crashed (stale socket)
if ! timeout 1 "$EWW" ping >/dev/null 2>&1; then
  if ! pgrep -f -- "$EWW daemon" >/dev/null; then
    rm -f "${XDG_RUNTIME_DIR:-/tmp}"/eww-server_*
    "$EWW" daemon >/dev/null 2>&1 9>&- &
  fi
  for _ in {1..20}; do timeout 1 "$EWW" ping >/dev/null 2>&1 && break; sleep 0.1; done
fi

case "$1" in
close)
  exec timeout 5 "$EWW" close-all
  ;;
toggle)
  if timeout 3 "$EWW" windows 2>/dev/null | grep -q '^\*c_backdrop'; then
    exec timeout 5 "$EWW" close-all
  fi
  ;;
esac

exec timeout 5 "$EWW" open-many "${WINDOWS[@]}"
