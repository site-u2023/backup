#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

mkdir -p /tmp/config-software2

cat <<"EOF" > /usr/bin/aio
#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="https://raw.githubusercontent.com/site-u2023/config-software2/main/"
BASE_DR="/tmp/config-software2/"

select_language() {
    echo -e "------------------------------------------------------"
    echo -e "Select your language:"
    echo -e "[e]: English"
    echo -e "[j]: 日本語"
    echo -e "------------------------------------------------------"
    read -p "Choose an option [e/j]: " lang_choice
    case "${lang_choice}" in
        "e") SELECTED_LANGUAGE="en" ;;
        "j") SELECTED_LANGUAGE="ja" ;;
        *) echo -e "$(color "red" "Invalid choice, defaulting to English.")" ;;
    esac
export SELECTED_LANGUAGE
}

supported_versions="19 21 22 23 24 SN"
release=$(grep 'DISTRIB_RELEASE' /etc/openwrt_release | cut -d"'" -f2 | cut -c 1-2)
if echo "${supported_versions}" | grep -q "${release}"; then
    echo -e "OpenWrt version: ${release} - Supported"
else
    echo -e "Unsupported OpenWrt version: ${release}"
    echo -e "Supported versions: ${supported_versions}"
    exit 1
fi

LANGUAGE=$1
#echo "選択された言語: $LANGUAGE"  # 引数を表示

if [ "$LANGUAGE" = "en" ]; then
    SELECTED_LANGUAGE="en"
    export SELECTED_LANGUAGE
elif [ "$LANGUAGE" = "ja" ]; then
    SELECTED_LANGUAGE="ja"
    export SELECTED_LANGUAGE
else
    select_language
fi

#echo "選択された言語: $SELECTED_LANGUAGE"  # 引数を表示
#read -p "STOP"

wget --no-check-certificate -O ${BASE_DR}main-colors.sh ${BASE_URL}main-colors.sh
wget --no-check-certificate -O ${BASE_DR}openwrt-config.sh ${BASE_URL}openwrt-config.sh
sh ${BASE_DR}openwrt-config.sh
EOF
chmod +x /usr/bin/aio
