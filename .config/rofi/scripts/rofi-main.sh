#!/usr/bin/env sh

SYSTEM_LANG="$LANG"
export LANG='POSIX'
exec >/dev/null 2>&1

LANG="$SYSTEM_LANG" \
exec rofi -config "$DWM/.tmp/rofi-config.tmp" \
          -theme-str "@import \"$HOME/.config/rofi/themes/main.rasi\"" \
          -no-lazy-grab \
          -show drun

exit ${?}
