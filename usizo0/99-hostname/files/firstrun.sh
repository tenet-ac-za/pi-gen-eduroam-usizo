#!/bin/bash -e

[ -e /etc/default/usizo ] && . /etc/default/usizo
[ -e /boot/firmware/usizo.cfg ] && . /boot/firmware/usizo.cfg

# This is loosely based on the Rasberry Pi Imager's first-run script,
# and may be overwritten by setting options within it. In the absence
# of user-specified options, set a random but idempotent hostname.
CURRENT_HOSTNAME=$(cat /etc/hostname | tr -d " \t\n\r")
NEW_HOSTNAME="eduroam-usizo-$(cat /sys/class/net/eth0/address | sed -E 's/^([^:]{2}:){3}//g; s/://g')"
echo "${NEW_HOSTNAME}" > /etc/hostname
sed -i "s/127.0.1.1.*${CURRENT_HOSTNAME}/127.0.1.1\t${NEW_HOSTNAME}/g" /etc/hosts

# Set the console password
if [ -n "${PASSWORD}" -a "${PASSWORD}" != "%%FIRST_USER_PASS%%" ] ; then
    chpasswd <<<"%%FIRST_USER_NAME%%:${PASSWORD}"
fi

# Remove from run
sed -Ei 's| systemd.run.[^[:space:] ]+||g' /boot/firmware/cmdline.txt
exit 0
