#!/bin/sh
# License: CC0
# OpenWrt >= 19.07


check_language() {
if [ "$LANGUAGE" = "en" ]; then
    SELECTED_LANGUAGE="en"
elif [ "$LANGUAGE" = "ja" ]; then
    SELECTED_LANGUAGE="ja"
else
    echo -e "$(color "white" "------------------------------------------------------")"
    echo -e "$(color "white" "Select your language:")"
    echo -e "$(color "blue" "[e]: English")"
    echo -e "$(color "red" "[j]: 日本語")"
    echo -e "$(color "white" "------------------------------------------------------")"
    read -p "Choose an option [e/j]: " lang_choice
    case "${lang_choice}" in
        "e") SELECTED_LANGUAGE="en" ;;
        "j") SELECTED_LANGUAGE="ja" ;;
        *) 
            echo "Invalid choice, defaulting to English."
            SELECTED_LANGUAGE="en"
            ;;
    esac
fi
}
