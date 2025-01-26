
#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# This script is specifically designed for the initial setup of an all-in-one script.

SELECTED_LANGUAGE=$1
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main/"
BASE_DIR="/tmp/aios/"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"

mkdir -p "$BASE_DIR" || {
    echo "Failed to create BASE_DIR: $BASE_DIR"
    exit 1
}

RELEASE_VERSION=$(grep 'DISTRIB_RELEASE' /etc/openwrt_release | cut -d"'" -f2 | cut -c 1-2)
    if ! echo "${SUPPORTED_VERSIONS}" | grep -q "${RELEASE_VERSION}"; then
        echo "Unsupported OpenWrt version: ${RELEASE_VERSION}"
        echo "Supported versions: ${SUPPORTED_VERSIONS}"
        exit 1
    fi

check_ttyd_installed() {
    if command -v ttyd >/dev/null 2>&1; then
        echo "ttyd is already installed."
    else
        echo "ttyd is not installed."
        wget --no-check-certificate -O "${BASE_DIR}ttyd.sh" "${BASE_URL}ttyd.sh"
        sh "${BASE_DIR}ttyd.sh"
    fi
}

wget --no-check-certificate -O "/usr/bin/aios" "${BASE_URL}aios"
chmod +x /usr/bin/aios

echo "${SELECTED_LANGUAGE}" > "${BASE_DIR}check_language"
echo "${RELEASE_VERSION}" > "${BASE_DIR}check_version"

check_ttyd_installed
aios
