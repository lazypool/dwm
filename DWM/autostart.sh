#!/bin/bash

theme=${DWM_THEME:-"onedark"}

# shellcheck source=themes/onedark/bar.t
source "$DWM/themes/$theme/bar.t"
mkdir -p "$DWM/.tmp/"
touch "$DWM/.tmp/dwm-statusbar-placeholder.tmp"
touch "$DWM/.tmp/hdmi.tmp"
touch "$DWM/.tmp/pkgupdates.tmp"
touch "$DWM/.tmp/network.tmp"
touch "$DWM/.tmp/wifilst.tmp"
pipe="$DWM/.tmp/pipe.tmp"

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

hdmi() {
	cur=$(xrandr --query | grep -c "^HDMI-A-0 connected")
	if [ "$cur" -eq 1 ] && [ "$1" -eq 0 ]; then
		xrandr --output eDP --primary --mode 1920x1080 --pos 0x0 --output HDMI-A-0 --mode 1920x1080 --pos 1920x0
		notify-send "HDMI Connected" "Extended desktop enabled"
	elif [ "$cur" -eq 0 ] && [ "$1" -eq 1 ]; then
		xrandr --output eDP --primary --mode 1920x1080 --pos 0x0 --output HDMI-A-0 --off
		notify-send "HDMI Disconnected" "Single screen restored"
	fi
	printf '%d' "$cur"
}

mem() {
	val=$(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)
	printf '^b%s^^c%s^  ^d^' "$blk" "$blu"
	printf '^b%s^^c%s^ %s ^d^' "$blk" "$blu" "$val"
}

pkgupdates() {
	val=$(cat "$DWM/.tmp/pkgupdates.tmp" | wc -l)
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
	*) printf '^b%s^^c%s^  󰖪  ^b%s^^c%s^ Disconnected ^d^' "$red" "$blk" "$gry" "$wht" ;;
	esac
}

xset b off # turn off beeps
setxkbmap -layout us -variant colemak -option -option caps:swapescape -option lv3:ralt_alt
syndaemon -i 1 -t -K -R -d # ignore tappad when keys are pressed
fcitx5 &
cat "$HOME/.config/dunst/dunstrc" "$DWM/themes/$theme/dunstrc" >"$DWM/.tmp/dunstrc.tmp"
dunst -conf "$DWM/.tmp/dunstrc.tmp" >>/dev/null 2>&1 &
cp "$DWM/themes/$theme/rf.rasi" "$HOME/.config/rofi/themes/colorschemes.rasi"
cp "$DWM/themes/$theme/eww.scss" "$HOME/.config/eww/theme.scss"
"$DWM/eww" daemon >>/dev/null 2>&1 &
picom --config "$HOME/.config/picom/picom.conf" >>/dev/null 2>&1 &
xsetroot -name "$(cat "$DWM/.tmp/dwm-statusbar-placeholder.tmp")" # pre-render to avoid initial delay
tick=0
while true; do
	status="$(pkgupdates)&$(battery)&$(brightness)&$(cpu)&$(mem)&$(wlan)&$(clock)&$(vol)"
	echo "$status" >"$DWM/.tmp/dwm-statusbar-placeholder.tmp"
	xsetroot -name "$(cat "$DWM/.tmp/dwm-statusbar-placeholder.tmp")"
	hdmi "$(cat "$DWM/.tmp/hdmi.tmp")" >"$pipe" && mv "$pipe" "$DWM/.tmp/hdmi.tmp"
	[ "$((tick % 3600))" -eq 0 ] && checkupdates >"$pipe" && mv "$pipe" "$DWM/.tmp/pkgupdates.tmp"
	[ "$((tick % 2400))" -eq 0 ] && nmcli --field 'SECURITY,SSID' --terse device wifi list >"$pipe" && mv "$pipe" "$DWM/.tmp/wifilst.tmp"
	[ "$((tick % 1200))" -eq 0 ] && bash "$DWM"/testwlan.sh >"$pipe" && mv "$pipe" "$DWM/.tmp/network.tmp"
	sleep 1 && tick=$(((tick + 1) % 3600))
done
