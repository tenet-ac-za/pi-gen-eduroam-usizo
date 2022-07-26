#!/bin/bash -e

install -m 644 files/defaults "${ROOTFS_DIR}/etc/default/usizo"
install -m 644 files/usizo.cfg "${ROOTFS_DIR}/boot/"
install -m 755 files/usizo-watchdog.sh "${ROOTFS_DIR}/usr/bin/"
install -m 644 files/crontab "${ROOTFS_DIR}/etc/cron.d/usizo-vpn"
install -m 644 files/motd "${ROOTFS_DIR}/etc/motd"
