#!/bin/bash
# 获取 wifi 信息
# 需要 nmcli

_this=_wifi
tmpfile=/tmp/dwm_statusbar

update() {
	[[ ! "$(command -v nmcli)" ]] && echo command not found: nmcli && return
	sed -i '/^export '$_this'=.*$/d' $tmpfile
	wifi_text=$(nmcli | grep "connected to" | awk -F " connected to " '{print $2}')
	[[ ! "$wifi_text" ]] && wifi_text="disconnected"
	wifi_icon="🛜"
	printf "export %s=' %s'\n" "$_this" "$wifi_icon" >> $tmpfile
}

notify() {
	update
	notify-send "🛜 Wifi" "$wifi_text" -r 9527
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
