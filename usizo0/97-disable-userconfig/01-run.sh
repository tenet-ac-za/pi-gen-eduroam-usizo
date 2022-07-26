#!/bin/bash -e

on_chroot << EOF
systemctl disable userconfig
systemctl mask userconfig
EOF

# deal with username change
sed -i "s/^pi/${FIRST_USER_NAME}/" "${ROOTFS_DIR}/etc/sudoers.d/010_pi-nopasswd"
rm -f "${ROOTFS_DIR}/etc/ssh/sshd_config.d/rename_user.conf"
