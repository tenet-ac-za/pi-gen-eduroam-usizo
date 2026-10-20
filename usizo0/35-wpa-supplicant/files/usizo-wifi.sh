#!/bin/sh

[ -e /etc/default/usizo ] && . /etc/default/usizo
[ -e /boot/usizo.cfg ] && . /boot/usizo.cfg

: ${WPA_USERNAME:=${USERNAME}@${REALM}}
: ${WPA_ANONYMOUS:=anonymous@${REALM}}
: ${WPA_PASSWORD:=${PASSWORD}}

if [ ! -e /etc/wpa_supplicant/wpa_supplicant.conf.tmpl ] ; then
	# clear out an existing network block
	sed -E '/^[[:space:]]*network=\{/{:1;/[[:space:]]+\}[[:space:]]*$/!{N;b1};d}' /etc/wpa_supplicant/wpa_supplicant.conf > /etc/wpa_supplicant/wpa_supplicant.conf.tmpl
	chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf.tmpl
fi
cp /etc/wpa_supplicant/wpa_supplicant.conf.tmpl /etc/wpa_supplicant/wpa_supplicant.conf

if [ -n "${WPA_COUNTRY}" ] ; then
	sed -Ei "s/country[[:space:]]*=.*$/country=${WPA_COUNTRY}/" /etc/wpa_supplicant/wpa_supplicant.conf
fi

cat <<-EOM >> /etc/wpa_supplicant/wpa_supplicant.conf
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
    sed -Ei 's/eap=PEAP/eap=PEAP\n phase1="peaplabel=1"/' /etc/wpa_supplicant/wpa_supplicant.conf
fi

exit 0
