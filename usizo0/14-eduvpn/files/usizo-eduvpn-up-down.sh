#!/bin/bash

. /usr/local/lib/usizo-functions

INTERFACE=$1
ACTION=$2

[[ "${INTERFACE}" == wg* ]] || exit 0

LOCALADDR4=$(ip -4 -o addr show dev ${INTERFACE} | awk '{print $4}' | cut -d/ -f1)
LOCALADDR6=$(ip -6 -o addr show dev ${INTERFACE} | awk '{print $4}' | cut -d/ -f1)

case "${ACTION}" in
	up)
		ENDPOINT=$(wg show wg0 endpoints | cut -f2)
		if [ "${ENDPOINT}" = "127.0.0.1:51820" ] ; then
			usizolog "using proxyguard endpoint, setting listen-port"
			wg set ${INTERFACE} listen-port 51821
			wg set ${INTERFACE} fwmark 54321
		fi
		if [ -n "${EDUVPN_ROUTES}" ] ; then
			for route in ${EDUVPN_ROUTES} ; do
				ip route add $route dev ${INTERFACE} table eduvpn metric 100
			done
		fi
		ip rule add from ${LOCALADDR4} table eduvpn priority 100
		ip -6 rule add from ${LOCALADDR6} table eduvpn priority 100
		#ip rule add iif ${INTERFACE} table eduvpn priority 101
		# let us know if the device comes up ;-)
		[ -e /usr/local/bin/usizo-watchdog.sh ] && sudo -u nobody /usr/local/bin/usizo-watchdog.sh
	;;

	postdown)
		ip route flush table eduvpn
		ip rule flush table eduvpn
	;;
esac

# telemetry to tell us what's happening
usizotelemetry "iface=${INTERFACE}" "address=${LOCALADDR4}" "state=${ACTION}"

exit 0
