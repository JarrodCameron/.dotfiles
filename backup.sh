#!/usr/bin/env bash

# Author: Jarrod Cameron (z5210220)
# Date:   18/03/19 20:37

# Colors
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
BOLD="\e[1m"
RESET="\e[0m"
ULINE="\e[4m"

# Path to the .dotfiles
DOTFILES_SRC="$HOME""/.dotfiles"

# Path to the dotfiles
I3WM_PATH="$HOME""/.config/i3"
BASHRC_PATH="$HOME""/.bashrc"
SCRIPTS_PATH="$HOME""/.scripts"
I3BLOCKS_PATH="$HOME""/.config/i3blocks"
XRESOURCES="$HOME""/.Xresources"
TMUX_CONF_PATH="$HOME""/.tmux.conf"
VIM_PATH="$HOME""/.vim"

# .dotfiles needs to be located in the home directory
if [ ! -d "$HOME""/.dotfiles" ]; then
  echo -e "$BOLD""ERROR:"$RESET" .dotfiles needs to be in the home directory!"
  exit 1
fi

# Create a `files' folder to store the files
if [ ! -d "$HOME""/.dotfiles/files/" ]; then
  mkdir "$HOME""/.dotfiles/files/"
fi


if [ -d ~/.config/i3 ]; then
  cp -r ~/.config/i3 ~/.dotfiles/files
  echo -e "$GREEN""i3/ successfully backed up""$RESET"
else
  echo -e "$RED""i3/ can't be backed up""$RESET"
fi

if [ -f ~/.bashrc ]; then
  cp ~/.bashrc ~/.dotfiles/files
  echo -e "$GREEN"".bashrc successfully backed up""$RESET"
else
  echo -e "$RED"".bashrc can't be backed up""$RESET"
fi

if [ -d ~/.scripts ]; then
  cp -r ~/.scripts ~/.dotfiles/files
  echo -e "$GREEN"".scripts/ successfully backed up""$RESET"
else
  echo -e "$RED"".scripts/ can't be backed up""$RESET"
fi

if [ -d ~/.config/i3blocks ]; then
  cp -r ~/.config/i3blocks ~/.dotfiles/files
  echo -e "$GREEN""i3blocks/ successfully backed up""$RESET"
else
  echo -e "$RED""i3blocks/ can't be backed up""$RESET"
fi

if [ -f ~/.Xresources ]; then
  cp ~/.Xresources ~/.dotfiles/files
  echo -e "$GREEN"".Xresources successfully backed up""$RESET"
else
  echo -e "$RED"".Xresources can't be backed up""$RESET"
fi

if [ -f ~/.tmux.conf ]; then
  cp ~/.tmux.conf ~/.dotfiles/files
  echo -e "$GREEN"".tmux.conf successfully backed up""$RESET"
else
  echo -e "$RED"".tmux.conf can't be backed up""$RESET"
fi

if [ -d ~/.vim ]; then
  cp -r ~/.vim ~/.dotfiles/files
  echo -e "$GREEN"".vim/ successfully backed up""$RESET"
else
  echo -e "$RED"".vim/ can't be backed up""$RESET"
fi


