#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

mkdir -p /tmp/config-software2

BASE_URL="https://raw.githubusercontent.com/site-u2023/config-software2/main/"
BASE_DIR="/tmp/config-software2/"

wget --no-check-certificate -O "${BASE_DIR}ttyd.sh" "${BASE_URL}ttyd.sh"
wget --no-check-certificate -O "/usr/bin/aio/aio" "${BASE_URL}aio"
chmod +x /usr/bin/aio

aio
