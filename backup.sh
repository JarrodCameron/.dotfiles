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
DOTFILES_SUCK="${DOTFILES_HOME}""/suckless/"

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

# Creates a diff of the repo and backs up
back_up_suckless () {
    local prog="$1"
    if [ -d "${DOTFILES_HOME}/suckless/${prog}" ]; then
        if [ -r "${DOTFILES_HOME}/suckless/${prog}/config.h" ]; then
            lastmod_confdefh="$(stat --format=%Y "${DOTFILES_HOME}/suckless/${prog}/config.def.h")"
            lastmod_confh="$(stat --format=%Y "${DOTFILES_HOME}/suckless/${prog}/config.h")"
            if [ "$lastmod_confdefh" -lt "$lastmod_confh" ]; then
                cp "${DOTFILES_HOME}/suckless/${prog}/config.h" "${DOTFILES_HOME}/suckless/${prog}/config.def.h"
            fi
        fi
        echo "${GREEN}""git-diff ${prog} backed up""${RESET}"
        git -C "${DOTFILES_HOME}/suckless/${prog}/" diff > "${DOTFILES_SRC}/${prog}.diff"
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

back_up_suckless "dwm"
back_up_suckless "dmenu"
back_up_suckless "st"
