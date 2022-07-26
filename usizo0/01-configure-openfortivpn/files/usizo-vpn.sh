#!/bin/sh

[ -e /etc/default/usizo ] && . /etc/default/usizo
[ -e /boot/usizo.cfg ] && . /boot/usizo.cfg

VPN_IP=$(echo "${VPN_SERVER}" | grep -P '^(\d{1,3}\.){3}\d{1,3}$')
if [ -z "$VPN_IP" ]; then
	VPN_IP=$(dig +short a "$VPN_SERVER" | grep -P '^(\d{1,3}\.){3}\d{1,3}$')
fi
: ${VPN_IP:=${VPN_SERVER}}

# force the VPN to always use eth0
ip route replace ${VPN_IP} via $(ip -o route show default dev eth0 | sed -E 's/^.*via (([0-9]{1,3}\.){3}[0-9]{1,3}).*$/\1/') dev eth0 proto static metric 1

exec /usr/bin/openfortivpn "${VPN_SERVER}:${VPN_PORT}" --username="${USERNAME}@${REALM}" --password="${PASSWORD}" --config=/etc/openfortivpn/usizo-vpn.conf ${OPENFORTIVPN_ARGS}
