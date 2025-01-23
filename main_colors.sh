#! /bin/sh

# Color settings
color_code_map() {
  local color=$1
  case $color in
    "red") echo "\033[1;31m" ;;
    "green") echo "\033[1;32m" ;;
    "yellow") echo "\033[1;33m" ;;
    "blue") echo "\033[1;34m" ;;
    "magenta") echo "\033[1;35m" ;;
    "cyan") echo "\033[1;36m" ;;
    "white") echo "\033[1;37m" ;;
    "white_black") echo "\033[7;40m" ;;
    "red_white") echo "\033[6;41m" ;;
    "reset") echo "\033[0;39m" ;;
    *) echo "\033[0;39m" ;;  # Fallback to reset
  esac
}

# Generic color function
color() {
  local color=$(color_code_map "$1")
  shift
  echo -e "${color}$*$(color_code_map "reset")"
}
