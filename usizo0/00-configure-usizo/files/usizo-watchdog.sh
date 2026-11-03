#!/bin/sh

. /usr/local/lib/usizo-functions

if [ -n "${USIZO_REBOOT:-}" ] ; then
    sleep 25
fi

ADDRESS=$(ip -4 -o addr list eth0 scope global primary | awk '{print $4}')
EDUVPN=$(ip -o link show wg0 2>/dev/null | awk '{print $3}')
SSID=$(iwgetid -r)
if [ -n "${SSID}" ] ; then
    SSID="${SSID}/$(iwgetid -r -a | tr A-F a-f)"
fi

WIFI_CACHE=/var/cache/usizo/wifi.json
if [ "${USIZO_SCAN_WIFI:-}" = "1" -a -r "${WIFI_CACHE}" ]; then
    WIFI_TIMESTAMP=$(stat -c %Y "${WIFI_CACHE}")
    usizotelemetry "iface=eth0" "address=${ADDRESS}" "POST:eduvpn=${EDUVPN}" "POST:ssid=${SSID}" \
        "POST:wifi@${WIFI_CACHE}" "POST:wifi_ts=${WIFI_TIMESTAMP}"
else
    usizotelemetry "iface=eth0" "address=${ADDRESS}" "POST:eduvpn=${EDUVPN}" "POST:ssid=${SSID}"
fi

if [ -n "${EDUVPN}" -a -n "${EDUVPN_WATCHDOG_PING}" ] ; then
    # poor man's keep alive
    ping -c 1 -n -q -I wg0 ${EDUVPN_WATCHDOG_PING} > /dev/null
fi

exit 0
