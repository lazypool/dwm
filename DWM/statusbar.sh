#!/bin/bash

theme=onedark

# shellcheck source=themes/onedark/bar.txt
source "$DWM/themes/$theme/bar.txt"
iconpath="$HOME/.local/share/icons/dwmStatus"

clkupdates() {
	:
}

clkbattery() {
	val=$(acpi | sed -n 's/.* \([0-9]\+\)%.*/\1/p' | head -1)
	duration=$(acpi -b | sed '2,$d' | awk -F'[,:]' '{h=$4; m=$5; printf "%dh %dmin\n", h, m}')
	if [ "$val" -gt 75 ]; then
		infix='full'
	elif [ "$val" -gt 50 ]; then
		infix='good'
	elif [ "$val" -gt 25 ]; then
		infix='low'
	else
		infix='empty'
	fi
	if acpi | grep -q 'Discharging'; then
		posfix=''
		stat='Discharging'
		desc='Available'
	else
		posfix='-charging'
		stat='Charging'
		desc='Full after'
	fi
	icon="$iconpath/battery-$infix$posfix.svg"
	if [ "$1" = "L" ]; then
		timeout 0 dunstify --app-name=status-toast-calendar --raw_icon="$icon" -r 9527 -t 5000 \
			"$val $stat" "$desc <span color='""$red""'>$duration</span>"
	fi
}

clkbrightness() {
	val=$(brightnessctl | sed -n 's/.*(\([0-9]\+\)%).*/\1/p')
	notify() {
		timeout 0 dunstify --app-name=status-toast-brightness --raw_icon="$iconpath/brightness.svg" -r 9527 -t 5000 \
			-h "int:value:$val" "$val"
	}
	case "$1" in
	"L") notify ;;
	"U") brightnessctl set 5%+ && notify ;;
	"D") brightnessctl set 5%- && notify ;;
	esac
}

clkcpu() {
	if [ "$1" = "L" ]; then
		:
	elif [ "$1" = "R" ]; then
		:
	fi
}

clkmem() {
	if [ "$1" = "L" ]; then
		:
	elif [ "$1" = "R" ]; then
		:
	fi
}

clkwlan() {
	if [ "$1" = "L" ]; then
		:
	elif [ "$1" = "R" ]; then
		:
	fi
}

clkdate() {
	if [ "$1" = "L" ]; then
		timeout 0 dunstify --app-name=status-toast-calendar --raw_icon="$iconpath/calendar.svg" -r 9527 -t 5000 \
			"$(date '+%B %Y')" \
			"$(cal --color=always | sed "s/..7m/<span weight='bold' color='""$red""'>/;s/..0m/<\/span>/" | tail -n +3)"
	fi
}

clkvolume() {
	notify() {
		val=$(amixer sget Master | grep -oE '[0-9]{1,3}%' | head -1 | tr -d '%')
		timeout 0 dunstify --app-name=status-toast-volume --raw_icon="$iconpath/audio-speaker.svg" -r 9527 -t 5000 \
			-h "int:value:$val" "$val"
	}
	case "$1" in
	"L") notify ;;
	"U") amixer -q set Master 5%+ && notify ;;
	"D") amixer -q set Master 5%- && notify ;;
	esac
}

case "$1" in
0) clkupdates "$2" ;;
1) clkbattery "$2" ;;
2) clkbrightness "$2" ;;
3) clkcpu "$2" ;;
4) clkmem "$2" ;;
5) clkwlan "$2" ;;
6) clkdate "$2" ;;
7) clkvolume "$2" ;;
esac
