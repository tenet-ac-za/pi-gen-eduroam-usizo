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
PROXY_ENDPOINT=$(cat ${VPN_CONF_FILE} | grep 'ProxyEndpoint =' | head -1 | awk {'print $3'})
sed -i 's/^ProxyEndpoint =/#ProxyEndpoint =/' ${VPN_CONF_FILE}

# determine the "Peer IPs"
DNS_HOST=$(echo ${PROXY_ENDPOINT} | cut -d '/' -f 3)
PEER_IPS=$(host ${DNS_HOST} | grep "address" | awk {'print $NF'} | tr "\n" "," | sed 's/,$//')
if [ -z "${PEER_IPS}" ]; then
    echo "ERROR: unable to determine IP address(es) of ProxyEndpoint"
    exit 1
fi

# configure proxyguard-client
echo "TO=${PROXY_ENDPOINT}" | sudo tee ${CFG_FILE} > /dev/null
echo "PEER_IPS=${PEER_IPS}" | sudo tee -a ${CFG_FILE} > /dev/null
echo "LISTEN_PORT=51820" | sudo tee -a ${CFG_FILE} > /dev/null
echo "FORWARD_PORT=51821" | sudo tee -a ${CFG_FILE} > /dev/null
