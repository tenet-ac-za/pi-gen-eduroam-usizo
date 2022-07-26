#!/bin/bash -e

cat <<- EOF >> "${ROOTFS_DIR}/boot/config.txt"
	
	# usizo additions
	disable_splash=1
	hdmi_force_hotplug=1
	#hdmi_safe=1
EOF
#sed -i 's|console=tty1|console=tty3|' "${ROOTFS_DIR}/boot/cmdline.txt"
sed -i 's|$| consoleblank=0 vt.global_cursor_default=0|' "${ROOTFS_DIR}/boot/cmdline.txt"

install -m 640 files/splashscreen.service "${ROOTFS_DIR}/etc/systemd/system/"
install -m 644 files/eduroam-usizo-logo.png "${ROOTFS_DIR}/boot/"

on_chroot << EOF
systemctl enable splashscreen
EOF
