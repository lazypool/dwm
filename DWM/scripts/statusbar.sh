#!/bin/bash

_thisdir=$(cd $(dirname $0);pwd)
tmpfile=/tmp/dwm_statusbar
touch $tmpfile

# 更新模块内容
update() {
	[ ! "$1" ] && refresh && return
	[ -e "$_thisdir/status/$1.sh" ] && bash $_thisdir/status/$1.sh
	shift 1; update $*
}

# 更新状态栏
refresh() {
	_music='';_wifi='';_cpu='';_mem='';_date='';_vol='';_bat=''
	source $tmpfile
	xsetroot -name "$_music$_wifi$_cpu$_mem$_date$_vol$_bat "
}

# 定时更新程序
cron() {
	echo > $tmpfile
	let i=0
	while true; do
		to=()
		[ $((i % 10)) -eq 0 ]  && to=(${to[@]} wifi)
		[ $((i % 20)) -eq 0 ]  && to=(${to[@]} cpu mem vol icons)
		[ $((i % 300)) -eq 0 ] && to=(${to[@]} bat)
		[ $((i % 5)) -eq 0 ]   && to=(${to[@]} date music)
		[ $i -lt 30 ] && to=(wifi cpu mem date vol icons bat music)
		update ${to[@]}
		sleep 5; let i+=5
	done &
}

# 状态栏点击
click() {
	[ ! "$1" ] && return
	bash $_thisdir/status/$1.sh click $2
	update $1
	refresh
}

case $1 in
	cron) cron ;;
	update) shift 1; update $* ;;
	updateall|check) update icons music wifi cpu mem date vol bat ;;
	*) click $1 $2 ;;
esac
