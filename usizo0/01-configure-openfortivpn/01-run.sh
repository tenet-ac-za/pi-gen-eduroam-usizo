#!/bin/bash -e

install -m 644 files/usizo-vpn.conf "${ROOTFS_DIR}/etc/openfortivpn/"
install -m 755 files/usizo-vpn.sh "${ROOTFS_DIR}/usr/bin/"
install -m 644 files/usizo-vpn.service "${ROOTFS_DIR}/etc/systemd/system/"
install -m 755 files/ip-up "${ROOTFS_DIR}/etc/ppp/ip-up.d/999usizo-vpn"
install -m 755 files/ip-down "${ROOTFS_DIR}/etc/ppp/ip-down.d/999usizo-vpn"
install -m 644 files/rt_tables "${ROOTFS_DIR}/etc/iproute2/rt_tables.d/usizo-vpn.conf"

on_chroot << EOF
systemctl enable usizo-vpn
EOF
