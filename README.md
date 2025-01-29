# all in one scripts

New config software is being tested.

![main](https://github.com/user-attachments/assets/ebfc8ca2-a42e-470c-9a89-9b5e3eb4ccb8)

Dedicated configuration software for OpenWrt

January 25, 2025: version α

- Select your language
```sh
wget -O /tmp/aios-config.sh https://raw.githubusercontent.com/site-u2023/aios/main/aios-config.sh; sh /tmp/aios-config.sh
```

- English
```sh
wget -O /tmp/aios-config.sh https://raw.githubusercontent.com/site-u2023/aios/main/aios-config.sh; sh /tmp/aios-config.sh en
```

- 日本語
```sh
wget -O /tmp/aios-config.sh https://raw.githubusercontent.com/site-u2023/aios/main/aios-config.sh; sh /tmp/aios-config.sh ja
```

- --timestamping
```sh
opkg update && opkg install wget-ssl
```
```sh
wget -N /tmp/aios-config.sh https://raw.githubusercontent.com/site-u2023/aios/main/aios-config.sh; sh /tmp/aios-config.sh ja
```
