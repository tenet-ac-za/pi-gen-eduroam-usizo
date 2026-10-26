#!/bin/bash -e

install -m 644 files/defaults "${ROOTFS_DIR}/etc/default/usizo"
install -m 644 files/usizo.cfg "${ROOTFS_DIR}/boot/firmware/"
install -m 755 files/usizo-functions.sh "${ROOTFS_DIR}/usr/local/lib/usizo-functions"
install -m 755 files/usizo-watchdog.sh "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/usizo-set-datetime.sh "${ROOTFS_DIR}/usr/local/bin/"
install -m 644 files/crontab "${ROOTFS_DIR}/etc/cron.d/usizo"
install -m 644 files/motd "${ROOTFS_DIR}/etc/motd"

VERSION=$(date --iso-8601)
if [ -e "${BASE_DIR}/.git" ] ; then
    VERSION="${VERSION} / $(git rev-parse --short HEAD)"
fi
( echo "eduroam usizo (${VERSION})"; grep -vi usizo "${ROOTFS_DIR}/etc/issue" ) > "${STAGE_WORK_DIR}/issue"

install -m 644 "${STAGE_WORK_DIR}/issue" "${ROOTFS_DIR}/etc/issue"

# prepopulate the hosts file
for host in ${ADD_TO_HOSTS_FILE} ; do
    hn=$(echo "${host}" | cut -d/ -f1)
    ips=$(echo "${host}/" | cut -d/ -f2 | sed 's/,/ /')
    if [ -z "${ips}" ] ; then
        ips=$(host ${hn} | grep "address" | awk {'print $NF'})
    fi
    for ip in ${ips} ; do
        if ! grep -Eq "^${ip}[[:space:]]*${hn}" ${ROOTFS_DIR}/etc/hosts ; then
            printf "%s\t%s\n" "${ip}" "${hn}" >> ${ROOTFS_DIR}/etc/hosts
        fi
    done
done
