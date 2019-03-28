#!/usr/bin/env bash

# Author: Jarrod Cameron (z5210220)
# Date:   28/03/19 22:14

# Colors
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
BOLD="\e[1m"
RESET="\e[0m"
ULINE="\e[4m"

# Path to the .dotfiles
# If changed don't forget to update backup.sh
DOTFILES_SRC="${HOME}""/.dotfiles/files/"

# All the files are int $DOTFILES_SRC
# They are 'restored' by being pointed to with symlinks
function re_store () {
  local path="$1"
  if [ ! -e "${path}""/""${path}" ]; then
    echo -e "${RED}""${path} is not in "'$DOTFILES_SRC'"${RESET}"
    exit 1
  fi
  ????
}

# Create a `files' folder to store the files
if [ ! -d "${DOTFILES_SRC}" ]; then
  mkdir "${DOTFILES_SRC}"
  echo -e "${BOLD}""Creating directory in "'$DOTFILES_SRC'"${RESET}"
fi



