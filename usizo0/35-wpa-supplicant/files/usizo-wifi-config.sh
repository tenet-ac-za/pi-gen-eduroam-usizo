#!/bin/sh

. /usr/local/lib/usizo-functions

: ${WPA_USERNAME:=${USERNAME}@${REALM}}
: ${WPA_ANONYMOUS:=anonymous@${REALM}}
: ${WPA_PASSWORD:=${PASSWORD}}
: ${CFG_FILE:=/etc/wpa_supplicant/wpa_supplicant.conf}

if [ ! -e "${CFG_FILE}.tmpl" ] ; then
	# clear out an existing network block
	sed -E '/^[[:space:]]*network=\{/{:1;/[[:space:]]+\}[[:space:]]*$/!{N;b1};d}' "${CFG_FILE}" > "${CFG_FILE}.tmpl"
	chmod 600 "${CFG_FILE}.tmpl"
fi
cp "${CFG_FILE}.tmpl" "${CFG_FILE}"

if [ -n "${WPA_COUNTRY}" ] ; then
	sed -Ei "s/country[[:space:]]*=.*$/country=${WPA_COUNTRY}/" "${CFG_FILE}"
fi

cat<<-EOM >> "${CFG_FILE}"
	network={
	 ssid="$WPA_ESSID"
	 disabled=0
	 scan_ssid=1
	 proto=WPA RSN
	 key_mgmt=WPA-EAP
	 pairwise=CCMP
	 group=CCMP
	 eap=${WPA_EAP_METHOD}
	 phase2="${WPA_EAP_PHASE2}"
	 identity="${WPA_USERNAME}"
	 password="${WPA_PASSWORD}"
	 anonymous_identity="${WPA_ANONYMOUS}"
	}
EOM

if [ "${WPA_EAP_METHOD}" = 'PEAP' ] ; then
    sed -Ei 's/eap=PEAP/eap=PEAP\n phase1="peaplabel=1"/' "${CFG_FILE}"
fi

usizolog "usizo-wifi wrote config for ${WPA_ESSID} to ${CFG_FILE}"

exit 0
