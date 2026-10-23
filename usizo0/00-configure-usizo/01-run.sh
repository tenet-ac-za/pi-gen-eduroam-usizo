#!/bin/bash -e

install -m 644 files/defaults "${ROOTFS_DIR}/etc/default/usizo"
install -m 644 files/usizo.cfg "${ROOTFS_DIR}/boot/firmware/"
install -m 755 files/usizo-watchdog.sh "${ROOTFS_DIR}/usr/local/bin/"
install -m 644 files/crontab "${ROOTFS_DIR}/etc/cron.d/usizo-vpn"
install -m 644 files/motd "${ROOTFS_DIR}/etc/motd"

VERSION=$(date --iso-8601)
if [ -e "${BASE_DIR}/.git" ] ; then
    VERSION="${VERSION} / $(git rev-parse --short HEAD)"
fi
( echo "eduroam usizo (${VERSION})"; grep -vi usizo "${ROOTFS_DIR}/etc/issue" ) > "${STAGE_WORK_DIR}/issue"

install -m 644 "${STAGE_WORK_DIR}/issue" "${ROOTFS_DIR}/etc/issue"
