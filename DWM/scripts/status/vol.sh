#!/bin/bash
# 获取音量
# 需要 pactl

_this=_vol
tmpfile=/tmp/dwm_statusbar

update() {
	[[ ! "$(command -v pactl)" ]] && echo command not found: pactl && return
	vol_text=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '/Volume:/ {print $5}')
	vol_icon=""
	sed -i '/^export '$_this'=.*$/d' $tmpfile
	printf "export %s=' %s%s'\n" "$_this" "$vol_icon" "$vol_text" >> $tmpfile
}

notify() {
	update
	notify-send " Volume        $vol_text" -h int:value:$vol_text -h string:hlcolor:#c0caf5 -r 9527
}

click() {
	case "$1" in
		L) notify ;;
		R) "" ;;
		U) pactl set-sink-volume @DEFAULT_SINK@ +5%; notify ;;
		D) pactl set-sink-volume @DEFAULT_SINK@ -5%; notify ;;
	esac
}

case "$1" in
	click) click $2 ;;
	notify) notify ;;
	*) update ;;
esac
