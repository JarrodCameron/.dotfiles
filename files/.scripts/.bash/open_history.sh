#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   23/10/19 12:46

# This script was origionally inteded to scan though the history but now uses
#   a dictionary to store common commands. Use fzf on the list of common
#   commands. The selected command is executed

#HIST_FILE="$HOME""/.bash_history"
HIST_FILE="$HOME""/.dotfiles/secret/freq_cmds.txt"

cmd=$(cat "$HIST_FILE" | sort | fzf --layout=reverse --margin=3 --header="pwd: $(pwd)" --inline-info --cycle)

if [ -z "$cmd" ]; then
    exit 1
fi

eval "$cmd"
