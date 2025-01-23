#! /bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="https://raw.githubusercontent.com/site-u2023/config-software2/main/"
BASE_DR="/etc/config-software/"

wget --no-check-certificate -O ${BASE_DR}maine_colors.sh ${BASE_URL}maine_colors.sh

# Load color settings
source ${BASE_DR}maine_colors.sh

download_and_execute() {
  local script_name="$1"
  local url="$2"
  echo -e "$(color "blue" "Downloading and executing: ${script_name}")"
  wget --no-check-certificate -O "${BASE_DR}${script_name}" "${url}"
  sh "${BASE_DR}${script_name}"
}

menu_option() {
  local description="$1"
  local script_name="$2"
  local url="$3"
  while :; do
    echo -e "$(color "white" "${description}")"
    read -p "$(color "cyan" "Do you want to proceed? [y/n]: ")" choice
    case "${choice}" in
      "y" ) download_and_execute "${script_name}" "${url}"; break ;;
      "n" ) break ;;
    esac
  done
}

# Delete scripts and exit
delete_and_exit() {
    echo -e "$(color "red" "Deleting script and exiting.")"
    rm -rf ${BASE_DR}
    rm -rf /usr/bin/confsoft
    exit
}

check_openwrt_version() {
  local supported_versions="19 21 22 23 24"
  local release=$(grep 'DISTRIB_RELEASE' /etc/openwrt_release | cut -d"'" -f2 | cut -c 1-2)

  if echo "${supported_versions}" | grep -q "${release}"; then
    echo -e "$(color "white" "OpenWrt version: ${release} - Supported")"
  else
    echo -e "$(color "red" "Unsupported OpenWrt version: ${release}")"
    echo -e "$(color "white" "Supported versions: ${supported_versions}")"
    exit 1
  fi
}

color_code() {
for i in `seq 30 38` `seq 40 47` ; do
    for j in 0 1 2 3 4 5 6 7 ; do
        printf "\033[${j};${i}m"
        printf " ${j};${i} "
        printf "\033[0;39;49m"
        printf " "
    done
    printf "\n"
done
}

display_system_info() {
    local available_memory=$(free | awk '/Mem:/ { print int($4 / 1024) }')
    local available_flash=$(df | awk '/overlayfs:\/overlay/ { print int($4 / 1024) }')
    local usb_devices=$(ls /sys/bus/usb/devices | grep -q usb && echo "Detected" || echo "Not detected")

    echo -e "$(color "white" "OpenWrt-Config Information")"
    echo -e "$(color "white" "Available Memory: ${available_memory} MB")"
    echo -e "$(color "white" "Available Flash Storage: ${available_flash} MB")"
    echo -e "$(color "white" "USB Devices: ${usb_devices}")"
    echo -e "$(color "white" "Script directory: /etc/config-software/")"
    echo -e "$(color "red" "Disclaimer: Use this script at your own risk.")"
}

main_menu() {
  while :; do
    echo -e "$(color "white" "-------------------------------------------------------")"
    echo -e "$(color "white" "OpenWrt Configuration Menu")"
    echo -e "$(color "blue" "[i]: Set up internet connection in Japan")"
    echo -e "$(color "yellow" "[s]: Perform initial system setup")"
    echo -e "$(color "green" "[p]: Install recommended packages")"
    echo -e "$(color "magenta" "[b]: Set up ad blocker and DNS encryption")"
    echo -e "$(color "red" "[a]: Configure access point connection")"
    echo -e "$(color "cyan" "[h]: Install Home Assistant")"
    echo -e "$(color "white" "[e]: Download and execute other scripts")"
    echo -e "$(color "white" "[q]: Quit this script")"
    echo -e "$(color "white_black" "[d]: Delete scripts and exit")"
    echo -e "$(color "white" "-------------------------------------------------------")"
    read -p "$(color "white" "Select an option: ")" option
    case "${option}" in
      "i" ) menu_option "Set up internet connection" "internet-config.sh" "${BASE_URL}internet-config.sh" ;;
      "s" ) menu_option "Perform initial system setup" "system-config.sh" "${BASE_URL}system-config.sh" ;;
      "p" ) menu_option "Install recommended packages" "package-config.sh" "${BASE_URL}package-config.sh" ;;
      "b" ) menu_option "Set up ad blocker and DNS encryption" "ad-dns-blocking-config.sh" "${BASE_URL}ad-dns-blocking-config.sh" ;;
      "a" ) menu_option "Configure access point connection" "dumb-config.sh" "${BASE_URL}dumb-config.sh" ;;
      "h" ) menu_option "Install Home Assistant" "homeassistant.sh" "${BASE_URL}homeassistant.sh" ;;
      "e" ) menu_option "Download and execute other scripts" "etc-config.sh" "${BASE_URL}etc-config.sh" ;;
      "q" ) exit ;;
      "d" ) delete_and_exit ;;
    esac
  done
}

# Main execution
check_openwrt_version
color_code
display_system_info
main_menu
