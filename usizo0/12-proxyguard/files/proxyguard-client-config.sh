#!/bin/sh

# based on https://codeberg.org/eduVPN/proxyguard/src/branch/main/contrib/vpn_setup.sh

if [ -z ${1} ]; then
    echo "ERROR: specify WireGuard VPN configuration file"
    exit 1
fi

VPN_CONF_FILE=${1}
if ! [ -f ${VPN_CONF_FILE} ]; then
    echo "ERROR: Missing file '${VPN_CONF_FILE}'"
    exit 1
fi

if [ -n "${2}" ] ; then
    CFG_FILE=${2}
else
    echo "WARNING: overwriting default config file"
    CFG_FILE=/etc/default/proxyguard-client
fi

# extract ProxyEndpoint, and comment the field
PROXY_ENDPOINT=$(sed -nE 's/^[[:space:]]*#?[[:space:]]*ProxyEndpoint[[:space:]]*=[[:space:]]*([^[:space:]]+).*/\1/Ip' "$VPN_CONF_FILE" | head -n 1)
sed -Ei 's/^ProxyEndpoint[[:space:]]*=/#ProxyEndpoint =/' ${VPN_CONF_FILE}

resolve_peer_ips() {
    if [ -n "${2}" ]; then
        host -W 2 -R 1 "${1}" "${2}" 2>/dev/null
    else
        host -W 2 -R 1 "${1}" 2>/dev/null
    fi | awk '
        / has address / || / has IPv6 address / {
            printf "%s%s", separator, $NF
            separator = ","
        }
    '
}

# determine the "Peer IPs"
DNS_HOST=$(printf '%s\n' "${PROXY_ENDPOINT}" | cut -d '/' -f 3)
PEER_IPS=$(getent ahosts "${DNS_HOST}" 2>/dev/null | awk '
    !seen[$1]++ {
        printf "%s%s", separator, $1
        separator = ","
    }
')
if [ -z "${PEER_IPS}" ]; then
    for resolver in 1.1.1.1 9.9.9.9 8.8.8.8; do
        echo "WARNING: system name resolution failed; trying DNS resolver ${resolver}" >&2
        PEER_IPS=$(resolve_peer_ips "${DNS_HOST}" "${resolver}")
        if [ -n "${PEER_IPS}" ]; then
            break
        fi
    done
fi
if [ -z "${PEER_IPS}" ]; then
    echo "ERROR: unable to determine IP address(es) of ProxyEndpoint"
    exit 1
fi

echo "<6>proxyguard-client wrote config for ${DNS_HOST} to ${CFG_FILE}"

# configure proxyguard-client
echo "TO=${PROXY_ENDPOINT}" | sudo tee ${CFG_FILE} > /dev/null
echo "PEER_IPS=${PEER_IPS}" | sudo tee -a ${CFG_FILE} > /dev/null
echo "LISTEN_PORT=51820" | sudo tee -a ${CFG_FILE} > /dev/null
echo "FORWARD_PORT=51821" | sudo tee -a ${CFG_FILE} > /dev/null
