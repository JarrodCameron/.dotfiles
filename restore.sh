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
DOTFILES_SUCK="${DOTFILES_HOME}""/suckless/"

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

# Clone the git repository. If the repository exists then refresh.
# apply the patch "${name}.diff" to the repository
#  <name> -> The name of the file (e.g. ".bashrc", ".vim")
#  <uri>  -> Location of repository to clone
restore_suckless () {
  local name="$1"
  local uri="$2"
  if [ -r "${DOTFILES_SRC}/${name}.diff" ]; then
    if [ -d "${DOTFILES_SUCK}/${name}" ]; then
      git -C "${DOTFILES_SUCK}/${name}" reset --hard 2>/dev/null
    else
      git clone "${uri}" "${DOTFILES_SUCK}/${name}"
    fi
    echo "${GREEN}${name} successfully restored${RESET}"
    git -C "${DOTFILES_SUCK}/${name}" apply "${DOTFILES_SRC}/${name}.diff"
    local retval="$?"
    if [ "${retval}" = "0" ]; then
      echo "${GREEN}${name} successfully patched${RESET}"
    else
      echo "${RED}${name} patch failed${RESET}"
    fi
  fi
}

# Create a `files' folder to store the files
if [ ! -d "${DOTFILES_SRC}" ]; then
  mkdir "${DOTFILES_SRC}"
  echo "${BOLD}""Creating directory in "'$DOTFILES_SRC'"${RESET}"
fi

# Create a `suckless' folder
if [ ! -d "${DOTFILES_SUCK}" ]; then
  mkdir "${DOTFILES_SUCK}"
  echo "${BOLD}""Creating directory in "'$DOTFILES_SUCK'"${RESET}"
fi

# When adding/removing file remember to modify `backup.sh'
#restore "i3"          "${HOME}""/.config/i3"
#restore ".bashrc"     "${HOME}""/.bashrc"
#restore ".scripts"    "${HOME}""/.scripts"
#restore "i3blocks"    "${HOME}""/.config/i3blocks"
#restore ".Xresources" "${HOME}""/.Xresources"
#restore ".tmux.conf"  "${HOME}""/.tmux.conf"
#restore ".vim"        "${HOME}""/.vim"
#restore "radare2rc"   "${HOME}""/.config/radare2/radare2rc"

# Suckless utils don't care about file system path
restore_suckless "dwm"   'git://git.suckless.org/dwm'
restore_suckless "dmenu" 'https://git.suckless.org/dmenu'
restore_suckless "st"    'https://git.suckless.org/st'
