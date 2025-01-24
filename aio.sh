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

download_script() {
wget --no-check-certificate -O ${BASE_DR}main-colors.sh ${BASE_URL}main-colors.sh
wget --no-check-certificate -O ${BASE_DR}openwrt-config.sh ${BASE_URL}openwrt-config.sh
}

language() {
LANGUAGE=$1
case "$LANGUAGE" in
    "en")
        SELECTED_LANGUAGE="en"
        export SELECTED_LANGUAGE
        ;;
    "ja")
        SELECTED_LANGUAGE="ja"
        export SELECTED_LANGUAGE
        ;;
    *)
        select_language
        ;;
esac
}

select_language() {
. "${BASE_DR}main-colors.sh"
    echo -e "$(color "white" "-------------------------------------------------------")"
    echo -e "$(color "white" "Select your language:")"
    echo -e "$(color "white" "[e]: English")"
    echo -e "$(color "white" "[j]: 日本語")"
    echo -e "$(color "white" "-------------------------------------------------------")"
    read -p "$(color "white" "Choose an option [e/j]: ")" lang_choice
    case "${lang_choice}" in
        "e") SELECTED_LANGUAGE="en" ;;
        "j") SELECTED_LANGUAGE="ja" ;;
        *) echo -e "$(color "red" "Invalid choice, defaulting to English.")" ;;
    esac
export SELECTED_LANGUAGE
}

run_script() {
sh ${BASE_DR}openwrt-config.sh
}

download_script
language
run_script
EOF
chmod +x /usr/bin/aio
