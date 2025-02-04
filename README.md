# all in one scripts

New config software is being tested.

Dedicated configuration software for OpenWrt

January 25, 2025: version α

![main](https://github.com/user-attachments/assets/ebfc8ca2-a42e-470c-9a89-9b5e3eb4ccb8)

## デバイスアクセス

[PowerShell](https://learn.microsoft.com/ja-jp/powershell/scripting/what-is-windows-powershell?view=powershell-7.4)の開始

- キー入力：**`Win`+`x` > `a` > `はい`**

<details><summary>パワーシェル7のインストールとショートカット作成</summary>

```powershell:powershell
$currentVersion = $PSVersionTable.PSVersion
Write-Host "Current PowerShell version: $($currentVersion)"
$installed = Get-Command pwsh -ErrorAction SilentlyContinue
if ($installed) {
    Write-Host "PowerShell 7 is already installed. Skipping installation."
} else {
    Write-Host "Installing PowerShell 7..."
    $url = "https://aka.ms/install-powershell.ps1"
    Invoke-WebRequest -Uri $url -OutFile "install-powershell.ps1"
    .\install-powershell.ps1
    Write-Host "PowerShell 7 installation completed."
}
$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = "$desktop\PowerShell 7 (Admin).lnk"
$targetPath = "C:\Program Files\PowerShell\7\pwsh.exe"
$arguments = "-Command Start-Process pwsh -Verb runAs"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetPath
$shortcut.Arguments = $arguments
$shortcut.Description = "PowerShell 7 Administrator Shortcut"
$shortcut.WorkingDirectory = "$HOME"
$shortcut.IconLocation = $targetPath
$shortcut.Save()
Write-Host "PowerShell 7 administrator shortcut has been created."

```

---

</details>

[UCI（SSH）アクセス](https://openwrt.org/docs/guide-quick-start/sshadministration)

```powershell:powershell:初期設定用
ssh -o StrictHostKeyChecking=no -oHostKeyAlgorithms=+ssh-rsa root@192.168.1.1
```

- root@192.168.1.1's password:`初期値：パスワード無し`

<details><summary>SSHログイン出来ない場合:exclamation:</summary>

  - `%USERPROFILE%\.ssh\known_hosts` ※Windows隠しファイル
```powershell:powershell
Clear-Content .ssh\known_hosts -Force 
```

</details>

<details><summary>OpenSSHのインストールが無い場合:exclamation:</summary>

- 機能の確認
※Windows 10 Fall Creators Update(1709)以降標準搭載
```powershell:powershell
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
```
- 機能のインストール
```powershell:powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```
---

</details>

## オールインワンスクリプト初期設定

$1は曖昧な入力も受け付けます。

例: `wget -O /tmp/aios.sh https://raw.githubusercontent.com/site-u2023/aios/main/aios.sh; sh /tmp/aios.sh 日本`

例: `aios cn`

- 試験用
```sh
wget -O /tmp/aios.sh "https://raw.githubusercontent.com/site-u2023/aios/main/aios.sh?cache_bust=$(date +%s)"
sh /tmp/aios.sh
```

- --timestamping
```sh
opkg update && opkg install wget-ssl
```
```sh
wget --no-cache --timestamping -O /tmp/aios.sh https://raw.githubusercontent.com/site-u2023/aios/main/aios.sh; sh /tmp/aios.sh
```

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

- 한국어
```sh
wget -O /tmp/aios.sh https://raw.githubusercontent.com/site-u2023/aios/main/aios.sh; sh /tmp/aios.sh ko
```

aiosインストール後
- help
```sh
--help
```
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


