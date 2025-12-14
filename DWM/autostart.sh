#!/bin/bash

blk='#1e222a'
grn='#7eca9c'
wht='#abb2bf'
gry='#282c34'
blu='#7aa2f7'
red='#d47d85'
dbl='#668ee3'

battery() {
	val=$(acpi | sed -n 's/.* \([0-9]\+\)%.*/\1/p' | head -1)
	printf '^c%s^ ^b%s^ BAT' "$blk" "$red"
	printf '^c%s^ ^b%s^ %s ^b%s^' "$wht" "$gry" "$val" "$blk"
}

brightness() {
	val=$(brightnessctl | sed -n 's/.*(\([0-9]\+\)%).*/\1/p')
	printf '^c%s^   ' "$red"
	printf '^c%s^ %.0f' "$red" "$val"
}

clock() {
	printf '^c%s^ ^b%s^ 󱑆 ' "$blk" "$red"
	printf '^c%s^ ^b%s^ %s ^b%s^' "$wht" "$gry" "$(date '+%H:%M')" "$blk"
}

cpu() {
	val=$(grep -o "^[^ ]*" /proc/loadavg)
	printf '^c%s^ ^b%s^ CPU' "$blk" "$grn"
	printf '^c%s^ ^b%s^ %s ^b%s^' "$wht" "$gry" "$val" "$blk"
}

mem() {
	val=$(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)
	printf '^c%s^ ^b%s^  ' "$red" "$blk"
	printf '^c%s^ %s' "$red" "$val"
}

pkgupdates() {
	updates=$({ timeout 20 checkupdates 2>/dev/null || true; } | wc -l)
	if [ -z "$updates" ]; then
		printf '  ^c%s^    Fully Updated' "$grn"
	else
		printf '  ^c%s^    %s updates' "$wht" "$updates"
	fi
}

vol() {
	printf ''
}

wlan() {
	case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
	up) printf '^c%s^ ^b%s^ 󰤨 ^d^ ^c%s^Connected' "$blk" "$blu" "$blu" ;;
	down) printf '^c%s^ ^b%s^ 󰤭 ^d^ ^c%s^Disconnected' "$blk" "$blu" "$blu" ;;
	esac
}

setxkbmap -layout us -variant colemak -option -option caps:swapescape -option lv3:ralt_alt
fcitx5 &
dunst -conf "$DWM"/dunst.conf &
picom --config "$DWM"/picom.conf >>/dev/null 2>&1 &
feh --randomize --bg-fill "$DWM"/wallpaper.jpg
updates=$(pkgupdates)
while true; do
	sleep 1 && xsetroot -name "$updates $(cpu) $(battery) $(mem) $(wlan) $(clock)"
done
