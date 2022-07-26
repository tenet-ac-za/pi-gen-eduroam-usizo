#!/bin/bash -e

# eduroam configuration for nmap
install -m 755 -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.nmap/"
install -m 644 -o 1000 -g 1000 files/nmap-services "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.nmap/"

echo "alias nmap-eduroam=\"nmap -e wlan0 -T4 -F ipv4.cat\"" >> "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bash_aliases"
echo "alias links-wlan=\"links -bind-address \\\"\$(ip -4 -o addr list wlan0 scope global primary | awk '{print \$4}' | sed 's|/.*$||')\\\"\"" >> "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bash_aliases"
echo "alias links-ppp=\"links -bind-address \\\"\$(ip -4 -o addr list ppp0 scope global primary | awk '{print \$4}' | sed 's|/.*$||')\\\"\"" >> "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bash_aliases"

echo "# not strictly aliases, but probably useful :)" >> "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bash_aliases"
echo "export IP_WLAN0=\"\$(ip -4 -o addr list wlan0 scope global primary | awk '{print \$4}' | sed 's|/.*$||')\"" >> "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bash_aliases"
echo "export IP_PPP0=\"\$(ip -4 -o addr list ppp0 scope global primary | awk '{print \$4}' | sed 's|/.*$||')\"" >> "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bash_aliases"
echo "export IP_ETH0=\"\$(ip -4 -o addr list eth0 scope global primary | awk '{print \$4}' | sed 's|/.*$||')\"" >> "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bash_aliases"
chown 1000:1000 "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bash_aliases"

# speedtest cli
url="https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-linux-armhf.tgz"
if [ ! -f "${STAGE_WORK_DIR}/speedtest" -o ! -f "${STAGE_WORK_DIR}/speedtest.5.gz" ] ; then
    echo "Fetching speedtest cli from ${url}" >&2
    curl -s "${url}" -o "$(basename "$url")"
    tar xz -C "${STAGE_WORK_DIR}" -f "$(basename "$url")" speedtest speedtest.5
    gzip "${STAGE_WORK_DIR}/speedtest.5"
fi

install -m 755 "${STAGE_WORK_DIR}/speedtest" "${ROOTFS_DIR}/usr/bin/"
install -m 644 "${STAGE_WORK_DIR}/speedtest.5.gz" "${ROOTFS_DIR}/usr/share/man/man5/"
