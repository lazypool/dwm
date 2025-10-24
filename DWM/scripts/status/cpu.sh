#!/bin/bash
# 获取 CPU 利用率和温度
# 需要 top, sensors

_this=_cpu
tmpfile=/tmp/dwm_statusbar

update() {
	[[ ! "$(command -v top)" ]] && echo command not found: top && return
	[[ ! "$(command -v sensors)" ]] && echo command not found: sensors && return
	cpu_text=$(top -n 1 -b | sed -n '3p' | awk '{printf "%02d%", 100 - $8}')
	cpu_icon="💻"
	temp_text=$(sensors | grep Tctl | awk '{printf "%d°C", $2}')
	temp_icon="🔥"
	sed -i '/^export '$_this'=.*$/d' $tmpfile
	printf "export %s=' %s%s %s%s'\n" "$_this" "$cpu_icon" "$cpu_text" "$temp_icon" "$temp_text" >> $tmpfile
}

notify() {
	notify-send "💻 CPU tops (%)" "$(ps axch -o cmd:15,%cpu --sort=-%cpu | head -n 8)" -r 9527
}

click() {
	case "$1" in
		L) notify ;;
		R) "" ;;
	esac
}

case "$1" in
	click) click $2 ;;
	notify) notify ;;
	*) update ;;
esac
