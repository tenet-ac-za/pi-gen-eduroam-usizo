#!/bin/bash -e

install -m 755 -D files/usizo-eduvpn-config.sh "${ROOTFS_DIR}/usr/local/sbin/"
install -m 755 files/usizo-eduvpn-up-down.sh "${ROOTFS_DIR}/usr/local/sbin/"
install -m 644 -D files/usizo-eduvpn.service "${ROOTFS_DIR}/usr/local/lib/systemd/system/"
