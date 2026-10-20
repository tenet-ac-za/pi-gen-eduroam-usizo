#!/bin/bash

[ -e /etc/default/usizo ] && . /etc/default/usizo
[ -e /boot/usizo.cfg ] && . /boot/usizo.cfg

INTERFACE=$1
ACTION=$2

[ "${INTERFACE}" == wg* ] || exit 0

LOCALADDR=$(wg show ${INTERFACE} address)
# telemetry to tell us what's happening
curl --silent --output /dev/null "${CALLBACK_URL}?usizo=$(cat /sys/class/net/eth0/address)&iface=${INTERFACE}&address=${LOCALADDR}&state=${ACTION}&ts=$(date +%s)"

case "${ACTION}" in:
	up)
		if [ -n "${EDUVPN_ROUTES}" ] ; then
			for route in ${EDUVPN_ROUTES} ; do
				ip route add $route dev ${INTERFACE} table eduvpn metric 100
			done
		fi
		ip rule add from ${LOCALADDR} table eduvpn priority 100
		ip rule add oif ${INTERFACE} table eduvpn priority 101
		# let us know if the device comes up ;-)
		[ -e /usr/bin/usizo-watchdog.sh ] && /usr/bin/usizo-watchdog.sh
		break
	;;

	postdown)
		ip route flush table eduvpn
		ip rule flush table eduvpn
		break
	;;
esac

exit 0
