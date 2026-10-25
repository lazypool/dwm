#!/bin/bash

EWW="${EWW:-$DWM/eww}"
DIALOGS=(c_session_shutdown c_session_reboot c_session_logout)

close_dialogs() {
	for window in "${DIALOGS[@]}"; do "$EWW" close "$window"; done
}

case "$1" in
open)
	case "$2" in
	shutdown) exec "$EWW" open c_session_shutdown ;;
	reboot) exec "$EWW" open c_session_reboot ;;
	logout) exec "$EWW" open c_session_logout ;;
	esac
	;;
close) close_dialogs ;;
do)
	close_dialogs
	case "$2" in
	shutdown) systemctl poweroff ;;
	reboot) systemctl reboot ;;
	logout) pkill dwm ;;
	esac
	;;
esac
