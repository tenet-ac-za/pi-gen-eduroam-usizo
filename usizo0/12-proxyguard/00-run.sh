#!/bin/bash -e

VERSION="2.1.1"

if [ ! -f "${STAGE_WORK_DIR}/proxyguard-${VERSION}.tar.xz" ] ; then
    curl -s -o "${STAGE_WORK_DIR}/proxyguard-${VERSION}.tar.xz" https://codeberg.org/eduVPN/proxyguard/releases/download/v${VERSION}/proxyguard-${VERSION}.tar.xz
fi
if [ ! -f "${STAGE_WORK_DIR}/proxyguard-${VERSION}/LICENSE" ] ; then
    tar xJv -C "${STAGE_WORK_DIR}" -f "${STAGE_WORK_DIR}/proxyguard-${VERSION}.tar.xz"
fi

if [ "${ARCH}" == "armhf" ] ; then
    export GOOS=linux
    export GOARCH=arm
    export GOARM=7
fi

env GOTOOLCHAIN=go1.26.0+auto  \
    go build -C "${STAGE_WORK_DIR}/proxyguard-${VERSION}" -o proxyguard-client codeberg.org/eduVPN/proxyguard/cmd/proxyguard-client/...

install -m 0755 -D "${STAGE_WORK_DIR}/proxyguard-${VERSION}/proxyguard-client" "${ROOTFS_DIR}/usr/local/sbin/proxyguard-client"
install -m 0644 -D files/proxyguard-client.target "${ROOTFS_DIR}/usr/local/lib/systemd/system/proxyguard-client.target"
install -m 0644 -D files/proxyguard-client@.service "${ROOTFS_DIR}/usr/local/lib/systemd/system/proxyguard-client@.service"
install -m 0755 -D files/proxyguard-client-config.sh "${ROOTFS_DIR}/usr/local/sbin/proxyguard-client-config.sh"
