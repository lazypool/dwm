#!/bin/bash

_thisdir=$(cd $(dirname $0);pwd)
tmpfile=$_thisdir/tmp
touch $tmpfile

# 设置某个模块的状态 update cpu mem ...
update() {
	[ ! "$1" ] && refresh && return                                       # 当指定模块为空时结束
	[ -e "$_thisdir/status/$1.sh" ] && bash $_thisdir/status/$1.sh        # 执行指定模块脚本
	shift 1; update $*                                                    # 递归调用
}

# 更新状态栏
refresh() {
	_icons='';_music='';_wifi='';_cpu='';_mem='';_date='';_vol='';_bat='' # 重置所有模块的状态为空
	source $tmpfile                                                       # 从 tmpfile 中读取模块的状态
	xsetroot -name "$_icons$_music$_wifi$_cpu$_mem$_date$_vol$_bat "      # 更新状态栏
}

# 启动定时更新状态栏 不同的模块有不同的刷新周期 注意不要重复启动该函数
cron() {
	echo > $tmpfile                                                       # 清空 tmp 文件
	let i=0
	while true; do
		to=()                                                               # 存放本次需要更新的模块
		[ $((i % 10)) -eq 0 ]  && to=(${to[@]} wifi)                        # 每 10秒  更新 wifi
		[ $((i % 20)) -eq 0 ]  && to=(${to[@]} cpu mem vol icons)           # 每 20秒  更新 cpu mem vol icons
		[ $((i % 300)) -eq 0 ] && to=(${to[@]} bat)                         # 每 300秒 更新 bat
		[ $((i % 5)) -eq 0 ]   && to=(${to[@]} date music)                  # 每 5秒   更新 date
		[ $i -lt 30 ] && to=(wifi cpu mem date vol icons bat music)         # 前 30秒  更新所有模块
		update ${to[@]}                                                     # 将需要更新的模块传递给 update
		sleep 5; let i+=5
	done &
}

# cron 启动定时更新状态栏
# update 更新指定模块 `update cpu` `update mem` `update date` `update vol` `update bat` 等
# updateall|check 更新所有模块
case $1 in
	cron) cron ;;
	update) shift 1; update $* ;;
	updateall|check) update icons music wifi cpu mem date vol bat ;;
esac
