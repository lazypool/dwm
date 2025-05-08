#!/bin/bash
# 获取电池电量
# 需要安装 acpi

_this=_bat
tmpfile=$(cd $(dirname $0);cd ..;pwd)/tmp

update() {
	[ ! "$(command -v acpi)" ] && echo command not found: acpi && return
	bat_text=" $(acpi -b | sed '2,$d' | awk '{print $4}' | grep -Eo "[0-9]+")% "
	bat_icon="  "
	charging=$(acpi -b | grep -q 'Battery 0.*Discharging' && echo "false" || echo "true")
	_time="Available: <b><span color='#ff79c6'>$(acpi | sed 's/^Battery 0: //g' | awk -F ',' '{print $3}' | sed 's/^[ ]//g' | awk '{print $1}')<\/span><\/b>"
	sed -i '/^export '$_this'=.*$/d' $tmpfile
	printf "export %s='%s%s'\n" "$_this" "$bat_icon" "$bat_text" >> $tmpfile
}

notify() {
	update
	[ "$charging" = "true" ] && _time=""
	notify-send " Battery     " "\nRemaining:<span color='#bd93f9'>$bat_text<\/span>\n$_time" -r 9527
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
