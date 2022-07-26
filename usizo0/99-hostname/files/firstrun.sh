#!/bin/bash -e
# This is loosely based on the Rasberry Pi Imager's first-run script,
# and may be overwritten by setting options within it. In the absence
# of user-specified options, set a random but idempotent hostname.
CURRENT_HOSTNAME=$(cat /etc/hostname | tr -d " \t\n\r")
NEW_HOSTNAME="eduroam-usizo-$(cat /sys/class/net/eth0/address | sed -E 's/^([^:]{2}:){3}//g; s/://g')"
echo "${NEW_HOSTNAME}" > /etc/hostname
sed -i "s/127.0.1.1.*${CURRENT_HOSTNAME}/127.0.1.1\t${NEW_HOSTNAME}/g" /etc/hosts

sed -Ei 's| systemd.run.[^[:space:] ]+||g' /boot/cmdline.txt
exit 0
