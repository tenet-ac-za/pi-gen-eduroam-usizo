#!/bin/sh

[ -e /etc/default/usizo ] && . /etc/default/usizo
[ -e /boot/usizo.cfg ] && . /boot/usizo.cfg

curl --silent --output /dev/null "${CALLBACK_URL}?usizo=$(cat /sys/class/net/eth0/address)&iface=eth0&address=$(ip -4 -o addr list eth0 scope global primary | awk '{print $4}')&ppp=$(ip -o link show ppp0 2>/dev/null | awk '{print $3}')&uptime=$(cat /proc/uptime | awk '{print $1}')&ts=$(date +\%s)"

exit 0
