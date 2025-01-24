#!/bin/sh

mkdir -p /tmp/config-software2

cat <<"EOF" > /usr/bin/aio
#!/bin/sh
wget --no-check-certificate -O /tmp/config-software2/main-colors.sh https://raw.githubusercontent.com/site-u2023/config-software2/main/main-colors.sh
wget --no-check-certificate -O /tmp/config-software2/openwrt-config.sh https://raw.githubusercontent.com/site-u2023/config-software2/main/openwrt-config.sh
sh /tmp/config-software2/openwrt-config.sh
EOF
chmod +x /usr/bin/aio
