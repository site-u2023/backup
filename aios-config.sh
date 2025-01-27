
#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# This script is specifically designed for the initial setup of an all-in-one script.

#SELECTED_LANGUAGE=$1
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main/"
BASE_DIR="${BASE_DIR:-/tmp/aios/}"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"

check_version() {
RELEASE_VERSION=$(grep 'DISTRIB_RELEASE' /etc/openwrt_release | cut -d"'" -f2 | cut -c 1-2)
    if ! echo "${SUPPORTED_VERSIONS}" | grep -q "${RELEASE_VERSION}"; then
        echo "Unsupported OpenWrt version: ${RELEASE_VERSION}"
        echo "Supported versions: ${SUPPORTED_VERSIONS}"
        exit 1
    fi
}

make_directory() {
mkdir -p "$BASE_DIR" || {
    echo "Failed to create BASE_DIR: $BASE_DIR"
    exit 1
    }
}

common_data() {
echo "${SELECTED_LANGUAGE}" > "${BASE_DIR}check_language"
echo "${RELEASE_VERSION}" > "${BASE_DIR}check_version"
}

check_ttyd_installed() {
    if command -v ttyd >/dev/null 2>&1; then
        echo "ttyd is already installed."
    else
        echo "ttyd is not installed."
        read -p "Do you want to install ttyd? (y/n): " choice
        case "$choice" in
            [Yy]*)
                echo "Installing ttyd..."
                wget --no-check-certificate -O "${BASE_DIR}ttyd.sh" "${BASE_URL}ttyd.sh"
                sh "${BASE_DIR}ttyd.sh"
                ;;
            [Nn]*)
                echo "Skipping ttyd installation."
                ;;
            *)
                echo "Invalid choice. Skipping ttyd installation."
                ;;
        esac
    fi
}

download_and_execute() {
    wget --no-check-certificate -O "/usr/bin/aios" "${BASE_URL}aios" || {
        echo "Failed to download aios."
        exit 1
    }
    chmod +x /usr/bin/aios
    aios
}

check_version
make_directory
common_data
check_ttyd_installed
download_and_execute

