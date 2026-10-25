#!/bin/bash

if pgrep -f '/usr/lib/flclash/FlClashCore' >/dev/null 2>&1; then
	id=$(xdotool search --class 'Com.follow.clash' 2>/dev/null | head -1)
	if [ -n "$id" ]; then
		xdotool windowactivate "$id" 2>/dev/null
		xdotool windowraise "$id" 2>/dev/null
	fi
else
	setsid -f flclash
fi
