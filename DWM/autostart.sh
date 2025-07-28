#! /bin/bash

_thisdir=$(cd $(dirname $0);pwd)

settings() {
	[ $1 ] && sleep $1
	xset -b                                     # 关闭蜂鸣器
	syndaemon -i 1 -t -K -R -d                  # 设置使用键盘时触控板短暂失效
	$_thisdir/scripts/set_screen.sh two         # 设置显示器 设置键盘映射
	setxkbmap -layout us -variant colemak -option -option caps:swapescape -option lv3:ralt_alt
}

daemons() {
	[ $1 ] && sleep $1
	$_thisdir/scripts/statusbar.sh cron &       # 开启状态栏定时更新
	xss-lock -- $_thisdir/scripts/blurlock.sh & # 开启自动锁屏程序
	fcitx5 &                                    # 开启输入法
	flameshot &                                 # 截图要跑一个程序在后台 不然无法将截图保存到剪贴板
	dunst -conf $_thisdir/scripts/config/dunst.conf &
	picom --config $_thisdir/scripts/config/picom.conf >> /dev/null 2>&1 &
}

cron() {
	[ $1 ] && sleep $1
	let i=10
	while true; do
		[ $((i % 10)) -eq 0 ] && $_thisdir/scripts/set_screen.sh check
		[ $((i % 300)) -eq 0 ] && feh --randomize --bg-fill ~/Pictures/wallpaper/*.png
		sleep 10; let i+=10                       # 更新壁纸和监视器
	done
}

settings &                                    # 初始化设置项
daemons &                                     # 后台程序项
cron &                                        # 定时任务项
