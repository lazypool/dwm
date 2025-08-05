#!/bin/bash
# 获取日期及时间
# 需要 date 命令

_this=_date
tmpfile=/tmp/dwm_statusbar

update() {
	[[ ! "$(command -v date)" ]] && echo command not found: date && return
	time_text=$(date '+%H:%M')
	time_icon=""
	sed -i '/^export '$_this'=.*$/d' $tmpfile
	printf "export %s=' %s%s'\n" "$_this" "$time_icon" "$time_text" >> $tmpfile
}

notify() {
	_cal=$(cal --color=always | sed 1d | sed '
		s/..7m/<b><span color="#ff79c6">/;s/..0m/<\/span><\/b>/;
		s/\(Su\|Mo\|Tu\|We\|Th\|Fr\|Sa\)/<span color="#bd93f9">\1<\/span>/g')
	notify-send " Calendar" "$_cal" -r 9527
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
