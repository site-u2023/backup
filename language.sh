#!/bin/sh
# License: CC0
# OpenWrt >= 19.07


if [ "$LANGUAGE" = "en" ]; then
    SELECTED_LANGUAGE="en"
elif [ "$LANGUAGE" = "ja" ]; then
    SELECTED_LANGUAGE="ja"
else
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
fi
