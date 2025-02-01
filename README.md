# all in one scripts

New config software is being tested.

![main](https://github.com/user-attachments/assets/ebfc8ca2-a42e-470c-9a89-9b5e3eb4ccb8)

Dedicated configuration software for OpenWrt

January 25, 2025: version α

$1は曖昧な入力も受け付けます。

例: `wget -O /tmp/aios.sh https://raw.githubusercontent.com/site-u2023/aios/main/aios.sh; sh /tmp/aios.sh 日本`

- Select your language
```sh
wget -O /tmp/aios.sh https://raw.githubusercontent.com/site-u2023/aios/main/aios.sh; sh /tmp/aios.sh
```

- English
```sh
wget -O /tmp/aios.sh https://raw.githubusercontent.com/site-u2023/aios/main/aios.sh; sh /tmp/aios.sh en
```

- 日本語
```sh
wget -O /tmp/aios.sh https://raw.githubusercontent.com/site-u2023/aios/main/aios.sh; sh /tmp/aios.sh ja
```

- 简体中文
```sh
wget -O /tmp/aios.sh https://raw.githubusercontent.com/site-u2023/aios/main/aios.sh; sh /tmp/aios.sh zh-cn
```

- 繁體中文
```sh
wget -O /tmp/aios.sh https://raw.githubusercontent.com/site-u2023/aios/main/aios.sh; sh /tmp/aios.sh zh-tw
```

- --timestamping
```sh
opkg update && opkg install wget-ssl
```
```sh
wget -N /tmp/aios.sh https://raw.githubusercontent.com/site-u2023/aios/main/aios.sh; sh /tmp/aios.sh ja
```

aiosインストール後
- aios
```sh
aios
```
- English
```sh
aios en
```
- Select your language（初期化）※再度wgetも初期化される
```sh
aios --reset
```


