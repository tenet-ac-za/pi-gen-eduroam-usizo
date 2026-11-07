#!/bin/bash -e

cat <<- EOF >> "${ROOTFS_DIR}/boot/firmware/config.txt"

	# usizo additions
	disable_splash=1
	hdmi_force_hotplug=1
	force_eeprom_read=0
	#hdmi_safe=1
EOF
#sed -i 's|console=tty1|console=tty3|' "${ROOTFS_DIR}/boot/firmware/cmdline.txt"
sed -i '/consoleblank=0/! s|$| consoleblank=0 vt.global_cursor_default=0|' "${ROOTFS_DIR}/boot/firmware/cmdline.txt"

install -m 644 files/usizo-splashscreen.service "${ROOTFS_DIR}/usr/local/lib/systemd/system/"
install -m 644 files/eduroam-usizo-logo.png "${ROOTFS_DIR}/boot/firmware/"

# keep the splash screen on tty1, but allow login on tty2
mkdir -p "${ROOTFS_DIR}/etc/systemd/getty@tty1.service.d"
cat <<- EOF > "${ROOTFS_DIR}/etc/systemd/getty@tty1.service.d/usizo.conf"
[Install]
WantedBy=
WantedBy=default.target
EOF
rm -f "${ROOTFS_DIR}/etc/systemd/system/getty.target.wants/getty@tty1.service"
