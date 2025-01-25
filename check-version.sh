#!/bin/sh
# License: CC0
# OpenWrt >= 19.07


check_version() {
RELEASE_VERSION=$(grep 'DISTRIB_RELEASE' /etc/openwrt_release | cut -d"'" -f2 | cut -c 1-2)
    if echo "${SUPPORTED_VERSIONS}" | grep -q "${RELEASE_VERSION}"; then
        echo "OpenWrt version: ${RELEASE_VERSION}.00.0 - Supported"
    else
        echo "Unsupported OpenWrt version: ${RELEASE_VERSION}"
        echo "Supported versions: ${SUPPORTED_VERSIONS}"
        exit 1
    fi
}
