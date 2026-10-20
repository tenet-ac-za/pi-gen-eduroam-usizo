#!/bin/bash -e

install -m 755 files/firstrun.sh "${ROOTFS_DIR}/boot/firmware/"
sed -i "s#%%FIRST_USER_NAME%%#${FIRST_USER_NAME}#g; s#%%FIRST_USER_PASS%%#${FIRST_USER_PASS}#g" "${ROOTFS_DIR}/boot/firmware/firstrun.sh"

sed -i '/systemd.run=/! s|$| systemd.run=/boot/firmware/firstrun.sh systemd.run_success_action=reboot|' "${ROOTFS_DIR}/boot/firmware/cmdline.txt"
