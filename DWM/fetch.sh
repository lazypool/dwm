#!/bin/bash

clear
tput civis
fastfetch
old_settings=$(stty -g)
stty -icanon -echo
dd bs=1 count=1 >/dev/null 2>&1
stty "$old_settings"
clear
