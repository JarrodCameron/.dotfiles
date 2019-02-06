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

# Link the i3wm
if [ "$(echo "$options" | grep -E "{full}|{i3}")" ]; then
  if [ "$(echo "$options" | grep "backup")" ]; then
    cp -r ~/.config/i3/ ~/.dotfiles/files/
    echo -e "$GREEN""Backed up: ""$BOLD""i3wm""$RESET"
  else
    mkdir -p ~/.config/i3/
    cp -r ~/.dotfiles/files/i3/ ~/.config/i3/
    echo -e "$GREEN""Successfully added: ""$BOLD""i3wm""$RESET"
  fi
fi

# Link the vim stuff
if [ "$(echo "$options" | grep -E "{full}|{vim}")" ]; then
  if [ "$(echo "$options" | grep "backup")" ]; then
    cp -r ~/.vim/ ~/.dotfiles/files/
    echo -e "$GREEN""Backed up: ""$BOLD"".vim/""$RESET"
  else
    mkdir -p ~/
    cp -r ~/.dotfiles/files/.vim/ ~/
    echo -e "$GREEN""Successfully added: ""$BOLD"".vim/""$RESET"
  fi
fi

# Link the .bashrc
if [ "$(echo "$options" | grep -E "{full}|{bash}")" ]; then
  if [ "$(echo "$options" | grep "backup")" ]; then
    cp -r ~/.bashrc ~/.dotfiles/files/
    echo -e "$GREEN""Backed up: ""$BOLD"".bashrc""$RESET"
  else
    mkdir -p ~/
    cp -r ~/.dotfiles/files/.bashrc ~/
    echo -e "$GREEN""Successfully added: ""$BOLD"".bashrc""$RESET"
  fi
fi

# Link the personal scripts
if [ "$(echo "$options" | grep -E "{full}|{scripts}")" ]; then
  if [ "$(echo "$options" | grep "backup")" ]; then
    cp -r ~/.scripts ~/.dotfiles/files/
    echo -e "$GREEN""Backed up: ""$BOLD"".scripts/""$RESET"
  else
    mkdir -p ~/
    cp -r ~/.dotfiles/files/.scripts ~/
    echo -e "$GREEN""Successfully added: ""$BOLD"".scripts/""$RESET"
  fi
fi

# Link i3blocks (status bar)
if [ "$(echo "$options" | grep -E "{full}|{i3blocks}")" ]; then
  if [ "$(echo "$options" | grep "backup")" ]; then
    cp -r ~/.config/i3blocks/ ~/.dotfiles/files/
    echo -e "$GREEN""Backed up: ""$BOLD""i3blocks/""$RESET"
  else
    mkdir -p ~/.config/i3blocks/
    cp -r ~/.dotfiles/files/i3blocks/ ~/.config/i3blocks/
    echo -e "$GREEN""Successfully added: ""$BOLD""i3blocks/""$RESET"
  fi
fi

# Link wallpapers
if [ "$(echo "$options" | grep -E "{full}|{wallpapers}")" ]; then
  if [ "$(echo "$options" | grep "backup")" ]; then
    cp -r ~/Pictures/wallpapers/ ~/.dotfiles/files/
    echo -e "$GREEN""Backed up: ""$BOLD""wallpapers/""$RESET"
  else
    mkdir -p ~/Pictures/wallpapers/
    cp -r ~/.dotfiles/files/wallpapers ~/Pictures/wallpapers/
    echo -e "$GREEN""Successfully added: ""$BOLD""wallpapers/""$RESET"
  fi
fi

# Link the .Xresources file
if [ "$(echo "$options" | grep -E "{full}|{xresources}")" ]; then
  if [ "$(echo "$options" | grep "backup")" ]; then
    cp -r ~/.Xresources ~/.dotfiles/files/
    echo -e "$GREEN""Backed up: ""$BOLD"".Xresources""$RESET"
  else
    mkdir -p ~/
    cp -r ~/.dotfiles/files/.Xresources ~/
    echo -e "$GREEN""Successfully added: ""$BOLD"".Xresources""$RESET"
  fi
fi
