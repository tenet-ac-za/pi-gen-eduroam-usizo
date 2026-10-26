#!/bin/sh

. /usr/local/lib/usizo-functions

ADDRESS=$(ip -4 -o addr list eth0 scope global primary | awk '{print $4}')
EDUVPN=$(ip -o link show wg0 2>/dev/null | awk '{print $3}')
usziotelemetry "iface=eth0" "address=${ADDRESS}" "eduvpn=${EDUVPN}"
exit 0
