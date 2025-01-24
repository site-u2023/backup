#!/bin/sh

mkdir -p /tmp/config-software2

cat <<"EOF" > /usr/bin/aio
#!/bin/sh
download_script() {
wget --no-check-certificate -O /tmp/config-software2/main-colors.sh https://raw.githubusercontent.com/site-u2023/config-software2/main/main-colors.sh
wget --no-check-certificate -O /tmp/config-software2/openwrt-config.sh https://raw.githubusercontent.com/site-u2023/config-software2/main/openwrt-config.sh
}
language() {
LANGUAGE=$1
if [ "$LANGUAGE" = "aioen" ]; then
    SELECTED_LANGUAGE="en"
    export SELECTED_LANGUAGE
elif [ "$LANGUAGE" = "aioja" ]; then
    SELECTED_LANGUAGE="ja"
    export SELECTED_LANGUAGE
else
    select_language
fi
}
select_language() {
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
sh /tmp/config-software2/openwrt-config.sh
}
download_script
language
run_script
EOF
chmod +x /usr/bin/aio
