#!/bin/sh

# Colors
RED="\e[31m"
GREEN="\e[32m"
BOLD="\e[1m"
RESET="\e[0m"

# Path to the .dotfiles
# If changed don't forget to update restore.sh
DOTFILES_SRC="${HOME}""/.dotfiles/files/"

back_up () {
  local path="$1"
  if [ -L "${path}" ]; then
    echo "${RED}""${path} is a symbolic link. Ignored.""${RESET}"
  elif [ -e "${path}" ]; then
    cp -r "${path}" "${DOTFILES_SRC}"
    echo "${GREEN}""${path} successfully backed up.""${RESET}"
  else
    echo "${RED}""${path} does not exist.""${RESET}"
  fi
}

# Create a `files' folder to store the files
if [ ! -d "${DOTFILES_SRC}" ]; then
  mkdir "${DOTFILES_SRC}"
  echo "${BOLD}""Creating directory in "'$DOTFILES_SRC'"${RESET}"
fi

# When adding/removing file remember to modify `restore.sh'
back_up "${HOME}""/.config/i3"
back_up "${HOME}""/.bashrc"
back_up "${HOME}""/.scripts"
back_up "${HOME}""/.config/i3blocks"
back_up "${HOME}""/.Xresources"
back_up "${HOME}""/.tmux.conf"
back_up "${HOME}""/.vim"
back_up "${HOME}""/Pictures/wallpapers"
