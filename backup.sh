#!/bin/bash

# Colors
RED="$(echo -e "\e[31m")"
GREEN="$(echo -e "\e[32m")"
BOLD="$(echo -e "\e[1m")"
RESET="$(echo -e "\e[0m")"

# Path to the .dotfiles
# If changed don't forget to update restore.sh
DOTFILES_HOME="${HOME}""/.dotfiles/"
DOTFILES_SRC="${DOTFILES_HOME}""/files/"

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
back_up "${HOME}""/.config/radare2/radare2rc"
back_up "${HOME}""/.config/termite/config"
back_up "${HOME}""/.gdbinit"
back_up "${HOME}""/.xmonad/xmonad.hs"
back_up "${HOME}""/.config/xmobar/xmobarrc"
back_up "${HOME}""/images/wallpapers"

