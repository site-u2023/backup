#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# This script is specifically designed for the initial setup of an all-in-one script.


BASE_URL="https://raw.githubusercontent.com/site-u2023/config-software2/main/"
BASE_DIR="/tmp/config-software2/"

mkdir -p "$BASE_DIR"
wget --no-check-certificate -O "${BASE_DIR}check-version.sh" "${BASE_URL}check-version.sh"
wget --no-check-certificate -O "${BASE_DIR}check-language.sh" "${BASE_URL}check-language.sh"
wget --no-check-certificate -O "${BASE_DIR}ttyd.sh" "${BASE_URL}ttyd.sh"
wget --no-check-certificate -O "/usr/bin/aios" "${BASE_URL}aios"
chmod +x /usr/bin/aios
