#!/bin/bash -e

install -m 644 files/defaults "${ROOTFS_DIR}/etc/default/usizo"
install -m 644 files/usizo.cfg "${ROOTFS_DIR}/boot/firmware/"
install -m 755 files/usizo-functions.sh "${ROOTFS_DIR}/usr/local/lib/usizo-functions"
install -m 755 files/usizo-watchdog.sh "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/usizo-set-datetime.sh "${ROOTFS_DIR}/usr/local/bin/"
install -m 644 -D files/usizo-datetime.service "${ROOTFS_DIR}/usr/local/lib/systemd/system/usizo-datetime.service"
install -m 644 files/crontab "${ROOTFS_DIR}/etc/cron.d/usizo"
install -m 644 files/motd "${ROOTFS_DIR}/etc/motd"
install -m 644 files/usizo-managed.conf /etc/NetworkManager/conf.d/usizo-managed.conf
install -m 644 -D files/issue "${ROOTFS_DIR}/etc/issue.d/00-usizo"

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
