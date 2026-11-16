#!/bin/bash

EWW="${EWW:-$DWM/eww}"
WINDOWS=(c_backdrop c_profile c_flclash c_background c_folders c_weather c_search c_quote c_shutdown c_logout c_reboot)

# wait for the autostarted daemon so clients don't spawn a second server
for _ in {1..150}; do "$EWW" ping >/dev/null 2>&1 && break; sleep 0.1; done

case "$1" in
close)
  exec "$EWW" close-all
  ;;
toggle)
  if "$EWW" windows 2>/dev/null | grep -q '^\*c_backdrop'; then
    exec "$EWW" close-all
  fi
  ;;
esac

exec "$EWW" open-many "${WINDOWS[@]}"
