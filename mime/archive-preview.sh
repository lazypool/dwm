#!/bin/bash

archive="$1"
file="$2"

case "$archive" in
*.zip)
	if [ -n "$file" ]; then
		unzip -p "$archive" "$file"
	else
		unzip -l "$archive"
	fi
	;;
*.rar)
	if [ -n "$file" ]; then
		unrar p -inul "$archive" "$file"
	else
		unrar l "$archive"
	fi
	;;
*.7z)
	if [ -n "$file" ]; then
		7z x -so "$archive" "$file"
	else
		7z l "$archive"
	fi
	;;
*.tar | *.tar.gz | *.tgz | *.tar.bz2 | *.tbz2 | *.tar.xz | *.txz)
	if [ -n "$file" ]; then
		tar -xOf "$archive" "$file"
	else
		tar -tf "$archive"
	fi
	;;
*.gz) gzip -dc "$archive" ;;
*.bz2) bzip2 -dc "$archive" ;;
*.xz) xz -dc "$archive" ;;
*) echo "Unsupported format" && exit 1 ;;
esac | nvim -R
