#!/bin/sh

. /usr/local/lib/usizo-functions

ADDRESS=$(ip -4 -o addr list eth0 scope global primary | awk '{print $4}')
EDUVPN=$(ip -o link show wg0 2>/dev/null | awk '{print $3}')
WIFI_CACHE=/var/cache/usizo/wifi.json
if [ "${USIZO_SCAN_WIFI:-}" = "1" -a -r "${WIFI_CACHE}" ]; then
    WIFI_TIMESTAMP=$(stat -c %Y "${WIFI_CACHE}")
    usizotelemetry "iface=eth0" "address=${ADDRESS}" "eduvpn=${EDUVPN}" \
        "POST:wifi@${WIFI_CACHE}" "POST:wifi_ts=${WIFI_TIMESTAMP}"
else
    usizotelemetry "iface=eth0" "address=${ADDRESS}" "eduvpn=${EDUVPN}"
fi

if [ -n "${EDUVPN}" -a -n "${EDUVPN_WATCHDOG_PING}" ] ; then
    # poor man's keep alive
    ping -c 1 -n -q -I wg0 ${EDUVPN_WATCHDOG_PING} > /dev/null
fi

exit 0
