#!/bin/bash

id=$(xdotool search --onlyvisible --class 'com.follow.clash' 2>/dev/null | head -1)

if [ -n "$id" ]; then
	xdotool windowactivate "$id" 2>/dev/null
	xdotool windowraise "$id" 2>/dev/null
else
	setsid -f flclash
fi
