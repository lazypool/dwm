#!/bin/bash

theme=onedark

# shellcheck source=themes/onedark/bar.txt
source "$DWM/themes/$theme/bar.txt"
tmpfile="$DWM/dwm-statusbar-placeholder.tmp"
[ ! -f "$tmpfile" ] && touch "$tmpfile"

battery() {
	bats='󰠈󰠉󰠊󰠋󰠌󰠍󰠎󰠏󰠐󰠇󰠇󰢜󰂆󰂇󰂈󰢝󰂉󰢞󰂊󰂋󰂅󰂅'
	val=$(acpi | sed -n 's/.* \([0-9]\+\)%.*/\1/p' | head -1)
	icon=${bats:$(("$val" / 10 + $(acpi | grep -q 'Discharging' && echo '0' || echo '11'))):1}
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
	if amixer get Master | grep -q -E '\[off\]|\[0%\]'; then
		printf '^b%s^^c%s^  󰝟   ^d^' "$blk" "$red"
	else
		printf '^b%s^^c%s^  󰕾   ^d^' "$blk" "$grn"
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
cat "$HOME/.config/dunst/dunstrc" "$DWM/themes/$theme/dunstrc" >"$DWM/dunstrc.tmp"
dunst -conf "$DWM/dunstrc.tmp" >>/dev/null 2>&1 &
picom --config "$HOME/.config/picom/picom.conf" >>/dev/null 2>&1 &
xsetroot -name "$(cat "$tmpfile")" # pre-render to avoid initial delay
updates=$(pkgupdates)
while true; do
	echo "$updates&$(battery)&$(brightness)&$(cpu)&$(mem)&$(wlan)&$(clock)&$(vol)" >"$tmpfile"
	xsetroot -name "$(cat "$tmpfile")" && sleep 60
done
