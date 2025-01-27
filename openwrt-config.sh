#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main/"
BASE_DIR="/tmp/aios/"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"

download_common() {
    if [ ! -f "${BASE_DIR}common-functions.sh" ]; then
        wget --no-check-certificate -O "${BASE_DIR}common-functions.sh" "${BASE_URL}common-functions.sh"
    fi
    source "${BASE_DIR}common-functions.sh"
}

ask_confirmation() {
    local message="$1"
    local yn_message="${2:-[y/n]}"
    read -p "$(color "white" "${message} ${yn_message}: ")" choice
    case "${choice}" in
        [Yy]*) return 0 ;;
        [Nn]*) return 1 ;;
        *) echo -e "$(color "red" "Invalid choice, please enter 'y' or 'n'.")"
           ask_confirmation "$message" "$yn_message" ;;
    esac
}

download_and_execute() {
    local script_name="$1"
    local description="$2"
    local url="$3"
    
    if ask_confirmation "Do you want to execute '${description}'?"; then
        echo -e "$(color "blue" "Downloading and executing: ${script_name}")"
        if wget --no-check-certificate -O "${BASE_DIR}${script_name}" "${url}"; then
            echo -e "$(color "green" "Download successful.")"
            sh "${BASE_DIR}${script_name}"
        else
            echo -e "$(color "red" "Download failed.")"
        fi
    else
        echo -e "$(color "yellow" "Operation aborted for ${description}.")"
    fi
}

exit_end() {
    if ask_confirmation "Are you sure you want to exit the script?"; then
        echo -e "$(color "white" "Exiting script.")"
        exit
    else
        echo -e "$(color "green" "Exit canceled.")"
    fi
}

delete_and_exit() {
    if ask_confirmation "Are you sure you want to delete the script and exit?"; then
        echo -e "$(color "red" "Deleting script and exiting.")"
        rm -rf "${BASE_DIR}" /usr/bin/aios /tmp/aios-config.sh
        exit
    else
        echo -e "$(color "green" "Deletion canceled.")"
    fi
}

main_menu() {
    local menu_entries=(
        "Internet settings (Japan Only):internet-config.sh"
        "Initial System Settings:system-config.sh"
        "Recommended Package Installation:package-config.sh"
        "Ad blocker installation settings:ad-dns-blocking-config.sh"
        "Access Point Settings:accesspoint-config.sh"
        "Other Script Settings:etc-config.sh"
        "Exit Script:exit_script"
        "Remove script and exit:delete_and_exit"
    )

    if [ "${SELECTED_LANGUAGE}" = "ja" ]; then
        menu_entries=(
            "インターネット設定:internet-config.sh"
            "システム初期設定:system-config.sh"
            "推奨パッケージインストール:package-config.sh"
            "広告ブロッカーインストール設定:ad-dns-blocking-config.sh"
            "アクセスポイント設定:accesspoint-config.sh"
            "その他のスクリプト設定:etc-config.sh"
            "スクリプト終了:exit_script"
            "スクリプト削除終了:delete_and_exit"
        )
    fi

    while :; do
        echo -e "$(color "white" "------------------------------------------------------")"
        for i in "${!menu_entries[@]}"; do
            local description="${menu_entries[$i]%%:*}"
            local key=$(printf "%c" $((97 + i))) # a, b, c... for options
            echo -e "$(color "blue" "[${key}] ${description}")"
        done
        echo -e "$(color "white" "------------------------------------------------------")"
        read -p "$(color "white" "Select an option: ")" option
        
        local index=$(( $(printf "%d" "'$option") - 97 )) # Convert char to index
        if [ "$index" -ge 0 ] && [ "$index" -lt "${#menu_entries[@]}" ]; then
            local selected_entry="${menu_entries[$index]}"
            local description="${selected_entry%%:*}"
            local script_name="${selected_entry##*:}"
            if [ "$script_name" = "exit_script" ]; then
                exit_end
            elif [ "$script_name" = "delete_and_exit" ]; then
                delete_and_exit
            else
                download_and_execute "${script_name}" "${description}" "${BASE_URL}${script_name}"
            fi
        else
            echo -e "$(color "red" "Invalid option. Please try again.")"
        fi
    done
}

download_common
main_menu
