#!/bin/sh

# Colors
RED="\e[31m"
GREEN="\e[32m"
BOLD="\e[1m"
RESET="\e[0m"

# Path to the .dotfiles
# If changed don't forget to update backup.sh
DOTFILES_HOME="${HOME}""/.dotfiles/"
DOTFILES_SRC="${DOTFILES_HOME}""/files/"
DOTFILES_SUCK="${DOTFILES_HOME}""/suckless/"

# All the files are int $DOTFILES_SRC
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
restore "i3"          "${HOME}""/.config/i3"
restore ".bashrc"     "${HOME}""/.bashrc"
restore ".scripts"    "${HOME}""/.scripts"
restore "i3blocks"    "${HOME}""/.config/i3blocks"
restore ".Xresources" "${HOME}""/.Xresources"
restore ".tmux.conf"  "${HOME}""/.tmux.conf"
restore ".vim"        "${HOME}""/.vim"
#restore "wallpapers"  "${HOME}""/Pictures/wallpapers"

if [ ! -d "${DOTFILES_SUCK}" ]; then
  mkdir "${DOTFILES_SUCK}"
  echo "${BOLD}""Creating directory in "'$DOTFILES_SUCK'"${RESET}"
fi

if [ -r "${DOTFILES_SRC}/dwm.diff" ]; then
    if [ -d "${DOTFILES_SUCK}" ]; then
        git -C "${DOTFILES_SUCK}/dwm" reset --hard >/dev/null
    else
        git clone git://git.suckless.org/dwm "${DOTFILES_SUCK}/dwm"
    fi
    echo "${GREEN}""dwm restored and patched""${RESET}"
    git -C "${DOTFILES_SUCK}/dwm" apply "${DOTFILES_SRC}/dwm.diff"
fi

if [ -r "${DOTFILES_SRC}/st.diff" ]; then
    if [ -d "${DOTFILES_SUCK}" ]; then
        git -C "${DOTFILES_SUCK}/st" reset --hard >/dev/null
    else
        git clone https://git.suckless.org/st "${DOTFILES_SUCK}/st"
    fi
    echo "${GREEN}""st restored and patched""${RESET}"
    git -C "${DOTFILES_SUCK}/st" apply "${DOTFILES_SRC}/st.diff"
fi
