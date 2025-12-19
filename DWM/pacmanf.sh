#!/bin/bash

echo -e '\033[0;32mtry to update, please enter password\033[0m'
if sudo pacman -Syyu; then
	if ! checkupdates; then
		printf '' >"$DWM/.tmp/pkgupdates.tmp"
		echo -e '\033[0;32mupdate ok, enter any key to quit\033[0m'
	fi
else
	echo -e '\033[0;32mupdate failed, please check the network\033[0m'
fi
old_settings=$(stty -g)
stty -icanon -echo
dd bs=1 count=1 >/dev/null 2>&1
stty "$old_settings"
