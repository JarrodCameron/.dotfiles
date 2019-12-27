#!/bin/bash

# Colors
RED="$(echo -e "\e[31m")"
GREEN="$(echo -e "\e[32m")"
BOLD="$(echo -e "\e[1m")"
RESET="$(echo -e "\e[0m")"

# Path to the .dotfiles
# If changed don't forget to update backup.sh
DOTFILES_HOME="${HOME}""/.dotfiles/"
DOTFILES_SRC="${DOTFILES_HOME}""/files/"

# All the files are in $DOTFILES_SRC
# They are 'restored' by being pointed to with symlinks
# restore <name> <path>
#  <name> -> The name of the file (e.g. ".bashrc", ".vim")
#  <path> -> The path to place the file (e.g. .vim goes in "$HOME/vim")
restore () {
  local name="$1"
  local path="$2"
  if [ -z "$name" ]; then
    echo "${RED}"Please specify name of file"${RESET}"
    exit 1
  elif [ -z "$path" ]; then
    echo "${RED}"Please specify file path"${RESET}"
    exit 1
  elif [ ! -e "${DOTFILES_SRC}""/""${name}" ]; then
    echo "${RED}""${name} is not in "'$DOTFILES_SRC'"${RESET}"
    exit 1
  fi

  if [ -e "${path}" ]; then
    # There is a file in the way and needs to be removed
    rm -rf "${path}"
  fi

  ln -s "${DOTFILES_SRC}""/""${name}" "${path}"
  local retval="$?"
  if [ "${retval}" = "0" ]; then
    echo "${GREEN}""${path} successfully restored""${RESET}"
  else
    echo "${RED}"ERROR: \`ln\' returned ${retval}"${RESET}"
  fi
}

# Create a `files' folder to store the files
if [ ! -d "${DOTFILES_SRC}" ]; then
  mkdir "${DOTFILES_SRC}"
  echo "${BOLD}""Creating directory in "'$DOTFILES_SRC'"${RESET}"
fi

# When adding/removing file remember to modify `backup.sh'
#restore "i3"          "${HOME}""/.config/i3"
restore ".bashrc"     "${HOME}""/.bashrc"
restore ".scripts"    "${HOME}""/.scripts"
#restore "i3blocks"    "${HOME}""/.config/i3blocks"
restore ".Xresources" "${HOME}""/.Xresources"
restore ".tmux.conf"  "${HOME}""/.tmux.conf"
restore ".vim"        "${HOME}""/.vim"
restore "radare2rc"   "${HOME}""/.config/radare2/radare2rc"
restore ".gdbinit"    "${HOME}""/.gdbinit"
restore ".xmonad.hs"  "${HOME}""/.xmonad/xmonad.hs"
restore "xmobarrc"    "${HOME}""/.config/xmobar/xmobarrc"
restore "wallpapers"  "${HOME}""/images/wallpapers"
