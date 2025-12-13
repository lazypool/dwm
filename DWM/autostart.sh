#!/bin/bash

setxkbmap -layout us -variant colemak -option -option caps:swapescape -option lv3:ralt_alt
fcitx5 &
dunst -conf "$DWM"/dunst.conf &
picom --config "$DWM"/picom.conf >> /dev/null 2>&1 &
feh --randomize --bg-fill "$DWM"/wallpaper.jpg
