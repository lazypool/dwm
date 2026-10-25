#!/bin/sh

LOCATION=""
CACHE="$HOME/.cache/eww/weather"
mkdir -p "$CACHE"
if [ -z "$LOCATION" ]; then
	LOCATION=$(curl -sf --max-time 6 "https://myip.ipip.net" 2>/dev/null | sed -n 's/.*来自于：[[:space:]]*//p' | awk '{print $3}')
fi
encoded_location=$(jq -rn --arg v "$LOCATION" '$v|@uri' 2>/dev/null)
stale=0
for file in ts icon temperature color condition city note tip; do
	[ -f "$CACHE/$file" ] || stale=1
done
if [ "$stale" = 0 ] && [ $(( $(date +%s) - $(cat "$CACHE/ts") )) -gt 1200 ]; then
	stale=1
fi
if [ "$stale" = 1 ]; then
	payload=$(curl -sf --max-time 8 "https://wttr.in/${encoded_location}?format=j1")
	if [ -n "$payload" ]; then
		temperature=$(printf '%s' "$payload" | jq -r '.current_condition[0].temp_C // "-"')
		condition=$(printf '%s' "$payload" | jq -r '.current_condition[0].weatherDesc[0].value // "N/A"')
		city=$(printf '%s' "$payload" | jq -r '.nearest_area[0].areaName[0].value // ""')
		condition_lower=$(printf '%s' "$condition" | tr '[:upper:]' '[:lower:]')
		hour=$(date +%H)
		is_night=0
		if [ "$hour" -lt 6 ] || [ "$hour" -ge 18 ]; then
			is_night=1
		fi
		case "$condition_lower" in
		*sunny* | *clear*)
			if [ "$is_night" = 1 ]; then icon=""; color="#fcdcf6"; note="It's a clear night."; tip="Take a stroll and relax."
			else icon=""; color="#ffd86b"; note="It's a sunny day, enjoy it!"; tip="Don't wander off too far."; fi ;;
		*partly*)
			if [ "$is_night" = 1 ]; then icon=""; color="#adadff"; note="Partly cloudy night."; tip="How about some hot chocolate?"
			else icon=""; color="#adadff"; note="Partly cloudy."; tip="A good day for a book."; fi ;;
		*cloud* | *overcast*) icon=""; color="#adadff"; note="It's cloudy and gloomy."; tip="A good time to read." ;;
		*rain* | *drizzle* | *shower*) icon=""; color="#6b95ff"; note="It's rainy."; tip="Get some ramen and watch the rain." ;;
		*thunder* | *storm*) icon=""; color="#ffeb57"; note="Storms expected today."; tip="Stay safe and dry." ;;
		*snow* | *sleet* | *ice* | *blizzard*) icon=""; color="#e3e6fc"; note="It's going to snow."; tip="Wear something warm." ;;
		*fog* | *mist* | *haze*) icon=""; color="#84afdb"; note="It's misty out."; tip="Do not get lost." ;;
		*) icon=""; color="#adadff"; note="Weather is odd today."; tip="Have a good time anyway!" ;;
		esac
		printf '%s' "$icon" > "$CACHE/icon"
		printf '%s' "$temperature" > "$CACHE/temperature"
		printf '%s' "$color" > "$CACHE/color"
		printf '%s' "$condition" > "$CACHE/condition"
		printf '%s' "$city" > "$CACHE/city"
		printf '%s' "$note" > "$CACHE/note"
		printf '%s' "$tip" > "$CACHE/tip"
		date +%s > "$CACHE/ts"
	fi
fi
case "$1" in
icon) cat "$CACHE/icon" 2>/dev/null ;;
temperature) cat "$CACHE/temperature" 2>/dev/null ;;
color) cat "$CACHE/color" 2>/dev/null ;;
condition) cat "$CACHE/condition" 2>/dev/null ;;
city) cat "$CACHE/city" 2>/dev/null ;;
note) cat "$CACHE/note" 2>/dev/null ;;
tip) cat "$CACHE/tip" 2>/dev/null ;;
esac
