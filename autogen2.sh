#!/usr/bin/env bash

# Author: Jarrod Cameron (z5210220)

# Colors
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
BOLD="\e[1m"
RESET="\e[0m"
ULINE="\e[4m"

print_banner () {
  echo -ne "$BOLD""$RED"
  echo "****************************************"
  echo "*       _       _    __ _ _            *"
  echo "*      | |     | |  / _(_) |           *"
  echo "*    __| | ___ | |_| |_ _| | ___  ___  *"
  echo "*   / _\` |/ _ \\| __|  _| | |/ _ \\/ __| *"
  echo "*  | (_| | (_) | |_| | | | |  __/\\__ \\ *"
  echo "* (_)__,_|\\___/ \\__|_| |_|_|\\___||___/ *"
  echo "*                                      *"
  echo "****************************************"
  echo ""
  echo -ne "$RESET"
}

usage () {
  echo "This is the usage"
}

# Backup all files to the .dotfiles/files/ directory
backup () {
  local loc="$1"
  local name="$2"
  local full_name="$loc""$name"
  if [ ! -e "$full_name" ]; then
    echo -e "$RED""ERROR: File does not exist ""$BOLD""$name""$RESET"
  else
    cp -r "$full_name" ~/.dotfiles/files/
    echo -e "$GREEN""Backed up: ""$BOLD""$name""$RESET"
  fi
}

# Distribute files through out the system
distribute () {
  local loc="$1"
  local name="$2"
  local full_name="$loc""$name"
  mkdir -p "$loc"
  cp -r ".dotfiles/files/""$name" "$loc"
  echo -e "$GREEN""Successfully added: ""$BOLD""$name""$RESET"
}


# If no args
if [ -z $1 ]; then
  usage
  exit 1
fi

options=""
for arg in "$@"; do
  case "${arg,,}" in
    "i3")         options+="{i3}"          ;;
    "vim")        options+="{vim}"         ;;
    "bash")       options+="{bash}"        ;;
    "scripts")    options+="{scripts}"     ;;
    "i3blocks")   options+="{i3blocks}"    ;;
    "wallpapers") options+="{wallpapers}"  ;;
    "xresources") options+="{xresources}"  ;;
    "full")       options+="{full}"        ;;
    "backup")     options+="{backup}"      ;;
    *) usage ; exit 0                      ;;
  esac
done

print_banner

# Linke the i3wm
if [ "$(echo "$options" | grep -E "{full}|{i3}")" ]; then
  if [ "$(echo "$options" | grep "backup")" ]; then
    backup ~/.config/ i3/
  else
    distribute ~/.config/ i3/
  fi
fi

# Link the vim stuff
if [ "$(echo "$options" | grep -E "{full}|{vim}")" ]; then
  if [ "$(echo "$options" | grep "backup")" ]; then
    backup ~/ .vim/
  else
    distribute ~/ .vim/
  fi
fi

# Link the .bashrc
if [ "$(echo "$options" | grep -E "{full}|{bash}")" ]; then
  if [ "$(echo "$options" | grep "backup")" ]; then
    backup ~/ .bashrc
  else
    distribute ~/ .bashrc
  fi
fi

# Link the personal scripts
if [ "$(echo "$options" | grep -E "{full}|{scripts}")" ]; then
  if [ "$(echo "$options" | grep "backup")" ]; then
    backup ~/ .scripts/
  else
    distribute ~/ .scripts/
  fi
fi

# Link i3blocks (status bar)
if [ "$(echo "$options" | grep -E "{full}|{i3blocks}")" ]; then
  if [ "$(echo "$options" | grep "backup")" ]; then
    backup ~/.config/ i3blocks/
  else
    distribute ~/.config/ i3blocks/
  fi
fi

# Link wallpapers
if [ "$(echo "$options" | grep -E "{full}|{wallpapers}")" ]; then
  if [ "$(echo "$options" | grep "backup")" ]; then
    backup ~/Pictures/ wallpapers/
  else
    distribute ~/Pictures/ wallpapers/
  fi
fi

# Link the .Xresources file
if [ "$(echo "$options" | grep -E "{full}|{xresources}")" ]; then
  if [ "$(echo "$options" | grep "backup")" ]; then
    backup ~/ .Xresources
  else
    distribute ~/ .Xresources
  fi
fi
