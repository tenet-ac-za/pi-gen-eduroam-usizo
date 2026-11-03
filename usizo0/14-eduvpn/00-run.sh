#!/bin/bash -e

install -m 755 files/usizo-eduvpn-config.sh "${ROOTFS_DIR}/usr/local/sbin/"
install -m 755 files/usizo-eduvpn-up-down.sh "${ROOTFS_DIR}/usr/local/sbin/"
install -m 644 files/usizo-eduvpn.service "${ROOTFS_DIR}/usr/local/lib/systemd/system/"
install -m 644 -D files/wg-quick-override.conf "${ROOTFS_DIR}/etc/systemd/system/wg-quick@.service.d/usizo-eduvpn.conf"
install -m 644 -D files/proxyguard-client-override.conf "${ROOTFS_DIR}/etc/systemd/system/proxyguard-client@.service.d/usizo-eduvpn.conf"
