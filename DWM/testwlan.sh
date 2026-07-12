#!/bin/bash

ping_output=$(ping -c 4 -W 2 "202.38.93.153" 2>/dev/null)
avg_ping=$(echo "$ping_output" | awk -F'/' '/rtt/ {print $5}')
avg_ping=${avg_ping:-timeout}

measure() {
    local mode=$1 size_mb=$2 start end dur curl_exit=0
    if [ "$mode" = "download" ]; then
        start=$(date +%s%N)
        curl -s -o /dev/null --max-time 10 --connect-timeout 3 "https://test.ustc.edu.cn/backend/download?size=${size_mb}MB" 2>/dev/null
        curl_exit=$?
        end=$(date +%s%N)
    else
        tmpfile=$(mktemp)
        dd if=/dev/zero of="$tmpfile" bs=1M count=1 2>/dev/null
        start=$(date +%s%N)
        curl -s -o /dev/null -X POST --data-binary @"$tmpfile" --max-time 10 --connect-timeout 3 "https://test.ustc.edu.cn/backend/upload" 2>/dev/null
        curl_exit=$?
        end=$(date +%s%N)
        rm -f "$tmpfile"
        size_mb=1
    fi
    if [ $curl_exit -ne 0 ]; then echo 0; return; fi
    dur=$(echo "scale=3; ($end - $start)/1000000000" | bc)
    if (( $(echo "$dur > 0" | bc) )); then echo "scale=2; $size_mb * 8 / $dur" | bc; else echo 0; fi
}

download_mbit=$(measure download 5)
upload_mbit=$(measure upload 5)
printf "Ping: %s ms\n" "$avg_ping"
printf "Download: %.2f Mbit/s\n" "$download_mbit"
printf "Upload: %.2f Mbit/s\n" "$upload_mbit"
