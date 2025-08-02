#!/bin/bash
# 音乐脚本
# 需要 mpd, mpc

_this=_music
tmpfile=/tmp/dwm_statusbar

update() {
	[ ! "$(command -v mpd)" ] && echo command not found: mpd && return
	[ ! "$(command -v mpc)" ] && echo command not found: mpc && return
	music_text=$(mpc current | sed 's/"/\\"/g')
	[ ! "$music_text" ] && music_text="No Playing"
	music_icon=""
	sed -i '/^export '$_this'=.*$/d' $tmpfile
	[ ! "$music_text" ] && return
	printf "export %s=' %s'\n" "$_this" "$music_icon" >> $tmpfile
}

notify() {
	update
	notify-send "$music_icon Music" "$music_text" -r 9527
}

click() {
	case "$1" in
		L) mpc toggle; notify ;;
		R) mpc pause; notify ;;
		U) mpc prev; notify ;;
		D) mpc next; notify ;;
	esac
}

case "$1" in
	click) click $2 ;;
	notify) notify ;;
	*) update ;;
esac
