#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# This script is specifically designed for the initial setup of an all-in-one script.


BASE_URL="https://raw.githubusercontent.com/site-u2023/config-software2/main/"
BASE_DIR="/tmp/config-software2/"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"

    RELEASE_VERSION=$(grep 'DISTRIB_RELEASE' /etc/openwrt_release | cut -d"'" -f2 | cut -c 1-2)
    if echo "${SUPPORTED_VERSIONS}" | grep -q "${RELEASE_VERSION}"; then
        echo "OpenWrt version: ${RELEASE_VERSION}.00.0 - Supported"
    else
        echo "Unsupported OpenWrt version: ${RELEASE_VERSION}"
        echo "Supported versions: ${SUPPORTED_VERSIONS}"
        exit 1
    fi

export BASE_URL
export BASE_DIR
export RELEASE_VERSION

mkdir -p "$BASE_DIR"
wget --no-check-certificate -O "${BASE_DIR}ttyd.sh" "${BASE_URL}ttyd.sh"
wget --no-check-certificate -O "/usr/bin/aios" "${BASE_URL}aios"
chmod +x /usr/bin/aios
# aios
