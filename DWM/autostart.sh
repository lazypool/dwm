#!/bin/bash

blk='#1e222a'
grn='#7eca9c'
wht='#abb2bf'
gry='#282c34'
blu='#7aa2f7'
red='#d47d85'
dbl='#668ee3'

batteryicons() {
	if acpi | grep -q 'Discharging'; then
		case "$1" in
		100) echo '󰠇' ;;
		9[0-9]) echo '󰠐' ;;
		8[0-9]) echo '󰠏' ;;
		7[0-9]) echo '󰠎' ;;
		6[0-9]) echo '󰠍' ;;
		5[0-9]) echo '󰠌' ;;
		4[0-9]) echo '󰠋' ;;
		3[0-9]) echo '󰠊' ;;
		2[0-9]) echo '󰠉' ;;
		*) echo '󰠈' ;;
		esac
	else
		case "$1" in
		100) echo '󰂅' ;;
		9[0-9]) echo '󰂋' ;;
		8[0-9]) echo '󰂊' ;;
		7[0-9]) echo '󰢞' ;;
		6[0-9]) echo '󰂉' ;;
		5[0-9]) echo '󰢝' ;;
		4[0-9]) echo '󰂈' ;;
		3[0-9]) echo '󰂇' ;;
		2[0-9]) echo '󰂆' ;;
		*) echo '󰢜' ;;
		esac
	fi
}

battery() {
	val=$(acpi | sed -n 's/.* \([0-9]\+\)%.*/\1/p' | head -1)
	icon=$(batteryicons "$val")
	printf '^b%s^^c%s^ %s ^d^' "$blk" "$blu" "$icon"
	printf '^b%s^^c%s^ %s ^d^' "$blk" "$blu" "$val"
}

brightness() {
	val=$(brightnessctl | sed -n 's/.*(\([0-9]\+\)%).*/\1/p')
	printf '^b%s^^c%s^  ^d^' "$blk" "$red"
	printf '^b%s^^c%s^ %.0f ^d^' "$blk" "$red" "$val"
}

clock() {
	printf '^b%s^^c%s^  󰥔  ^d^' "$dbl" "$blk"
	printf '^b%s^^c%s^ %s ^d^' "$blu" "$blk" "$(date '+%a,  %H:%M  %p') "
}

cpu() {
	val=$(grep -o "^[^ ]*" /proc/loadavg)
	printf '^b%s^^c%s^ CPU ^d^' "$grn" "$blk"
	printf '^b%s^^c%s^ %s ^d^' "$gry" "$wht" "$val"
}

mem() {
	val=$(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)
	printf '^b%s^^c%s^  ^d^' "$blk" "$blu"
	printf '^b%s^^c%s^ %s ^d^' "$blk" "$blu" "$val"
}

pkgupdates() {
	val=$({ timeout 20 checkupdates 2>/dev/null || true; } | wc -l)
	if [ "$val" -eq 0 ]; then
		printf '^b%s^^c%s^   󰬬   Fully Updated   ^d^' "$blk" "$grn"
	else
		printf '^b%s^^c%s^   󰬬   %s updates   ^d^' "$blk" "$wht" "$val"
	fi
}

vol() {
	val=$(amixer get Master | grep -o '\[off\]' | head -1)
	if [ -z "$val" ]; then
		printf '^b%s^^c%s^  󰕾   ^d^' "$blk" "$grn"
	else
		printf '^b%s^^c%s^  󰝟   ^d^' "$blk" "$red"
	fi
}

wlan() {
	case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
	up) printf '^b%s^^c%s^  󰖩  ^b%s^^c%s^ Connected ^d^' "$red" "$blk" "$gry" "$wht" ;;
	down) printf '^b%s^^c%s^  󰖪  ^b%s^^c%s^ Disconnected ^d^' "$red" "$blk" "$gry" "$wht" ;;
	esac
}

setxkbmap -layout us -variant colemak -option -option caps:swapescape -option lv3:ralt_alt
fcitx5 &
dunst -conf "$DWM"/dunst.conf &
picom --config "$DWM"/picom.conf >>/dev/null 2>&1 &
feh --randomize --bg-fill "$DWM"/wallpaper.jpg
updates=$(pkgupdates)
while true; do
	sleep 1 && xsetroot -name "$updates&$(battery)&$(brightness)&$(cpu)&$(mem)&$(wlan)&$(clock)&$(vol)"
done
