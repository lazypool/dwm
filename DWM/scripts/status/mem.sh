#!/bin/bash
# 获取当前内存使用

_this=_mem
tmpfile=/tmp/dwm_statusbar

update() {
	[[ ! "$(command -v cat)" ]] && echo command not found: cat && return
	mem_tota=$(cat /proc/meminfo | grep -w "MemTotal:"| awk '{print $2}')
	mem_free=$(cat /proc/meminfo | grep -w "MemFree:" | awk '{print $2}')
	mem_buff=$(cat /proc/meminfo | grep -w "Buffers:" | awk '{print $2}')
	mem_cach=$(cat /proc/meminfo | grep -w "Cached:"  | awk '{print $2}')
	mem_text=$(echo $(((mem_tota - mem_free - mem_buff - mem_cach) * 100 / mem_tota)) | awk '{printf "%02d%", $1}')
	mem_icon="💾"
	sed -i '/^export '$_this'=.*$/d' $tmpfile
	printf "export %s=' %s%s'\n" "$_this" "$mem_icon" "$mem_text" >> $tmpfile
}

notify() {
	notify-send "💾 Memory" "$(free -h | awk '
		NR==2 {a=$7;u=$3;t=$2} 
		NR==3 {s=$3"/"$2} 
		END {printf "Free: %s\nUsed: %s/%s\nSwap: %s", a, u, t, s}')" -r 9527
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
