#!/bin/bash

CACHE="$HOME/.cache/eww/quote"
mkdir -p "$CACHE"
stale=0
if [ ! -f "$CACHE/ts" ] || [ ! -f "$CACHE/text" ] || [ ! -f "$CACHE/author" ]; then
	stale=1
elif [ $(( $(date +%s) - $(cat "$CACHE/ts") )) -gt 600 ]; then
	stale=1
fi
if [ "$stale" = 1 ]; then
	skip=$(( $(od -An -N2 -tu2 /dev/urandom) % 80 ))
	payload=$(curl -sf --max-time 8 "https://dummyjson.com/quotes?limit=20&skip=$skip")
	if [ -n "$payload" ]; then
		entry=$(printf '%s' "$payload" | jq -r '.quotes as $q | ([$q[] | select((.quote|length) <= 120)][0] // ($q | sort_by(.quote|length))[0])')
		text=$(printf '%s' "$entry" | jq -r '.quote // ""')
		author=$(printf '%s' "$entry" | jq -r '.author // ""')
		printf '%s' "$text" > "$CACHE/text"
		printf '%s' "$author" > "$CACHE/author"
		date +%s > "$CACHE/ts"
	fi
fi
case "$1" in
text) cat "$CACHE/text" 2>/dev/null ;;
author) cat "$CACHE/author" 2>/dev/null ;;
esac
