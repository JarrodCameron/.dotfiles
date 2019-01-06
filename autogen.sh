#!/usr/bin/env bash

# Author: Jarrod Cameron (z5210220)

# TODO:
# - Create links depending on args
#   - `--full' will do everything
#   - `--help' will display usage
#   - `$name' will link the $name

usage () {
  echo "TODO: usage"
}

# If no args
if [ -z $1 ]; then
  usage
  exit 0
fi

options=""
for arg in "$@"; do
  case "$arg" in
    "vim")      options+="{vim}"      ;;
    "i3")       options+="{i3}"       ;;
    "i3blocks") options+="{i3blocks}" ;;
    "bash")     options+="{bash}"     ;;
    "scripts")  options+="{scripts}"  ;;
    *) usage ; exit 0                 ;;
  esac
done

if [ "$(grep "{vim}" <<< "$options")" ]; then
  echo "AAA"
fi
## Link the vim stuff
#ln -s "$HOME"/.dotfiles/files/vim "$HOME"/.vim
#
#ln -s "$HOME"/.dotfiles/files/i3 "$HOME"/.config/i3
#ln -s "$HOME"/.dotfiles/files/i3blocks "$HOME"/.config/i3blocks
#
## .bashrc
#ln -s "$HOME"/.dotfiles/files/bashrc "$HOME"/.bashrc
#
## Personal scripts
#ln -s "$HOME"/.dotfiles/files/scripts "$HOME"/.scripts
