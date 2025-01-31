#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# Initial setup script for running an all-in-one script (aios).

BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"
SELECTED_LANGUAGE=$1

check_version() {
    RELEASE_VERSION=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release | cut -c 1-2)
    if ! echo "${SUPPORTED_VERSIONS}" | grep -qw "${RELEASE_VERSION}"; then
        echo "Unsupported OpenWrt version: ${RELEASE_VERSION}"
        echo "Supported versions: ${SUPPORTED_VERSIONS}"
        exit 1
    fi
}

make_directory() {
    mkdir -p "$BASE_DIR"
}

check_ttyd_installed() {
    if ! command -v ttyd >/dev/null 2>&1; then
        echo "ttyd is not installed."
        read -p "Do you want to install ttyd? (y/n, default: n): " choice
        choice=${choice:-n}
        case "$choice" in
            [Yy]*)
                echo "Installing ttyd..."
                wget --quiet -O "${BASE_DIR}/ttyd.sh" "${BASE_URL}/ttyd.sh" || {
                    echo "Failed to download ttyd installation script."
                    exit 1
                }
                if [ ! -f "${BASE_DIR}/ttyd.sh" ]; then
                    echo "Error: ttyd installation script not found."
                    exit 1
                fi
                RELEASE_VERSION="${RELEASE_VERSION}" sh "${BASE_DIR}/ttyd.sh" "$SELECTED_LANGUAGE"
                ;;
            *)
                echo "Skipping ttyd installation."
                ;;
        esac
    fi
}

download_and_execute() {
    wget --quiet -O "/usr/bin/aios" "${BASE_URL}/aios" || {
        echo "Failed to download aios."
        exit 1
    }
    chmod +x /usr/bin/aios || {
        echo "Failed to set execute permissions on /usr/bin/aios"
        exit 1
    }
    echo -e "\nInstallation Complete"
    echo "aios has been installed successfully."
    echo "You can now run the 'aios' script anywhere."
    /usr/bin/aios "$1" || {
        echo "Failed to execute aios script."
        echo "${SELECTED_LANGUAGE}" > ${BASE_DIR}/check_language
        echo "${RELEASE_VERSION}" > ${BASE_DIR}/check_version
echo "download_and_execute: $SELECTED_LANGUAGE"
echo "download_and_execute result: $(cat ${BASE_DIR}/check_language; echo $?)"
        exit 1
    }
}

check_version
make_directory
check_ttyd_installed
download_and_execute
