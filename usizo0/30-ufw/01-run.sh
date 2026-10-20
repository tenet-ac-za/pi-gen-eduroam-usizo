#!/bin/bash -e

install -m 640 files/user.rules "${ROOTFS_DIR}/etc/ufw/"
install -m 640 files/user6.rules "${ROOTFS_DIR}/etc/ufw/"
sed -i 's/ENABLED=no/ENABLED=yes/' "${ROOTFS_DIR}/etc/ufw/ufw.conf"
