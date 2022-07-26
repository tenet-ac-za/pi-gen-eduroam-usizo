#!/bin/bash -e

if [ -n "${WPA_ESSID}" ] ; then
    echo "WPA_ESSI=${WPA_ESSID}" >> "${ROOTFS_DIR}/etc/default/usizo"
fi
if [ -n "${WPA_PASSWORD}" ] ; then
    echo "WPA_ESSI=${WPA_ESSID}" >> "${ROOTFS_DIR}/etc/default/usizo"
fi
if [ -n "${WPA_COUNTRY}" ] ; then
    echo "WPA_COUNTRY=${WPA_COUNTRY}" >> "${ROOTFS_DIR}/etc/default/usizo"
fi

install -m 755 files/usizo-wifi.sh "${ROOTFS_DIR}/usr/bin/"
install -m 644 files/usizo-wifi.service "${ROOTFS_DIR}/etc/systemd/system/"
install -m 755 files/dhcpcd "${ROOTFS_DIR}/lib/dhcpcd/dhcpcd-hooks/99-usizo-wifi"
install -m 644 files/rt_tables "${ROOTFS_DIR}/etc/iproute2/rt_tables.d/usizo-wifi.conf"

on_chroot << EOF
systemctl enable usizo-wifi
EOF
