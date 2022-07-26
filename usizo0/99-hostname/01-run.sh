#!/bin/bash -e

install -m 755 files/firstrun.sh "${ROOTFS_DIR}/boot/"
sed -i 's|$| systemd.run=/boot/firstrun.sh systemd.run_success_action=reboot|' "${ROOTFS_DIR}/boot/cmdline.txt"
