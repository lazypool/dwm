#!/bin/bash

theme=onedark

# shellcheck source=themes/onedark/bar.txt
source "$DWM/themes/$theme/bar.txt"
iconpath="$HOME/.local/share/icons/dwmStatus"
pipe="$DWM/.tmp/pipe.tmp"

clkupdates() {
	: # L -> call terminal and run `sudo pacman -Syyu`
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
		timeout 0 dunstify --app-name=status-toast-calendar --raw-icon="$icon" -r 9527 -t 5000 \
			"$val $stat" "$desc <span color='""$red""'>$duration</span>"
	fi
}

clkbrightness() {
	val=$(brightnessctl | sed -n 's/.*(\([0-9]\+\)%).*/\1/p')
	notify() {
		timeout 0 dunstify --app-name=status-toast-brightness --raw-icon="$iconpath/brightness.svg" -r 9527 -t 5000 \
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
		timeout 0 dunstify --app-name=status-toast-cpu --raw-icon="$iconpath/cpu.svg" -r 9527 -t 5000 \
			"$(sensors | grep Tctl | awk '{printf "%d°C", $2}') / $(grep -o "^[^ ]*" /proc/loadavg)" \
			"$(ps axch -o cmd:15,%cpu --sort=-%cpu | head)"
	elif [ "$1" = "R" ]; then
		: # call terminal and run btop
	fi
}

clkmem() {
	if [ "$1" = "L" ]; then
		timeout 0 dunstify --app-name=status-toast-mem --raw-icon="$iconpath/dotmemory.svg" -r 9527 -t 5000 \
			"$(free -h | awk '/^Mem:/{print $3 " / " $2}' | sed 's/i//g')" \
			"$(ps -eo rss,comm --sort=-rss --no-headers | awk 'NR <= 10 {printf "%-18s %.1f%s\n", substr($2,1,15)(length($2)>15?"...":""), ($1>1e6?$1/1e6:$1/1e3), ($1>1e6?"G":"M")}')"
	elif [ "$1" = "R" ]; then
		: # call terminal and run btop
	fi
}

clkwlan() {
	notifyInit() {
		ssid=$(nmcli -t -f 'name,type' connection show --active | awk -F: '$2 ~ /wireless|wifi|ethernet/ {print $1}' | head -1)
		if [ -z "$ssid" ]; then
			timeout 0 dunstify --app-name=status-toast-wlan --raw-icon="$iconpath/wifi-radar.svg" --action clicked,clk -r 9527 -t 5000 \
				"No Internet Connection" \
				"Unable to connect. <span color='$blu'>(click me to build a network connection)</span>"
		else
			timeout 0 dunstify --app-name=status-toast-wlan --raw-icon="$iconpath/wifi-radar.svg" --action clicked,clk -r 9527 -t 5000 \
				"$(ip -4 addr show scope global | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)" \
				"$(printf "%-10s%s\n" "SSID" "$ssid"; awk -F': ' '{printf "%-10s%s\n", $1, $2}' "$DWM/.tmp/network.tmp")"
		fi
	}
	notifySucc() {
		timeout 0 dunstify --app-name=status-toast-wlan --raw-icon="$iconpath/wifi-radar.svg" -r 9527 -t 5000 \
			"Connection Established" \
			"You are now connected to the Wi-Fi network <span color='$blu'>$1</span>"
		speedtest-cli --simple > "$pipe" && mv "$pipe" "$DWM/.tmp/network.tmp"
	}
	notifyFail() {
		timeout 0 dunstify --app-name=status-toast-wlan --raw-icon="$iconpath/wifi-radar.svg" -r 9527 -t 5000 \
			"Connection Failed" \
			"Please check if the SSID and password math"
	}
	[ "$1" != "L" ] && return
	click=$(notifyInit) # the base pop-up notification
	[ "$click" != "clicked" ] && return
	wifilst=$(cat "$DWM/.tmp/wifilst.tmp" | sed '1d; /:$/d; s/^:/󰈈 /; s/^.*:/ /' | sort -u)
	selected=$(echo -e "$wifilst" | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: ")
	[ -z "$selected" ] && return
	read -r selectedid <<<"${selected:2}"
	if nmcli -g NAME connection | grep -qw "$selectedid"; then
		if nmcli connection up id "$selectedid" | grep -q "success"; then
			notifySucc "$selected"
		else
			notifyFail
		fi
	else
		[[ "$selected" =~ "" ]] && password=$(rofi -dmenu -p "password: ")
		if nmcli device wifi connect "$selectedid" password "$password" | grep -q "success"; then
			notifySucc "$selected"
		else
			notifyFail
		fi
	fi
}

clkdate() {
	if [ "$1" = "L" ]; then
		timeout 0 dunstify --app-name=status-toast-calendar --raw-icon="$iconpath/calendar.svg" -r 9527 -t 5000 \
			"$(date '+%B %Y')" \
			"$(cal --color=always | sed "s/..7m/<span weight='bold' color='""$red""'>/;s/..0m/<\/span>/" | tail -n +3)"
	fi
}

clkvolume() {
	notify() {
		val=$(amixer sget Master | grep -oE '[0-9]{1,3}%' | head -1 | tr -d '%')
		timeout 0 dunstify --app-name=status-toast-volume --raw-icon="$iconpath/audio-speaker.svg" -r 9527 -t 5000 \
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
