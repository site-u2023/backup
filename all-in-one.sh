#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

mkdir -p /tmp/config-software2

cat <<"EOF" > /usr/bin/aio
#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

# Constants
BASE_URL="https://raw.githubusercontent.com/site-u2023/config-software2/main/"
BASE_DIR="/tmp/config-software2/"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"

# Function: Check OpenWrt version compatibility
check_version() {
    release=$(grep 'DISTRIB_RELEASE' /etc/openwrt_release | cut -d"'" -f2 | cut -c 1-2)
    if echo "${SUPPORTED_VERSIONS}" | grep -q "${release}"; then
        echo "OpenWrt version: ${release} - Supported"
    else
        echo "Unsupported OpenWrt version: ${release}"
        echo "Supported versions: ${SUPPORTED_VERSIONS}"
        exit 1
    fi
}

# Function: Display language selection menu
select_language() {
    echo "------------------------------------------------------"
    echo "Select your language:"
    echo "[e]: English"
    echo "[j]: 日本語"
    echo "------------------------------------------------------"
    read -p "Choose an option [e/j]: " lang_choice
    case "${lang_choice}" in
        "e") SELECTED_LANGUAGE="en" ;;
        "j") SELECTED_LANGUAGE="ja" ;;
        *) 
            echo "Invalid choice, defaulting to English."
            SELECTED_LANGUAGE="en"
            ;;
    esac
}

# Main script logic
LANGUAGE=$1
check_version

if [ "$LANGUAGE" = "en" ]; then
    SELECTED_LANGUAGE="en"
elif [ "$LANGUAGE" = "ja" ]; then
    SELECTED_LANGUAGE="ja"
else
    select_language
fi

export SELECTED_LANGUAGE

# Download and execute scripts
wget --no-check-certificate -O "${BASE_DIR}main-colors.sh" "${BASE_URL}main-colors.sh"
wget --no-check-certificate -O "${BASE_DIR}openwrt-config.sh" "${BASE_URL}openwrt-config.sh"
sh "${BASE_DIR}openwrt-config.sh"
EOF

chmod +x /usr/bin/aio
