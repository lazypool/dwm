#!/bin/bash
# 获取日期及时间

_this=_date
tmpfile=$(cd $(dirname $0);cd ..;pwd)/tmp

update() {
	time_text="$(date '+%m/%d %H:%M')"

	sed -i '/^export '$_this'=.*$/d' $tmpfile
	printf "export %s='%s'\n" "$_this" "$time_text" >> $tmpfile
}

case "$1" in
    click) click $2 ;;
    notify) notify ;;
    *) update ;;
esac
