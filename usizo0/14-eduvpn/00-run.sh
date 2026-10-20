#!/bin/bash -e

install -m 755 files/usizo-eduvpn-up-down.sh "${ROOTFS_DIR}/etc/wireguard/usizo-eduvpn-up-down.sh"
install -m 644 files/usizo-eduvpn.service "${ROOTFS_DIR}/usr/local/lib/systemd/system/usizo-eduvpn.service"
