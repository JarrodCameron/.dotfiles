#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   16/02/20 20:55

BOLD="\e[1m"
RESET="\e[0m"

TODO_PATH="$HOME"'/.cache/todo'

if [ ! -r "$TODO_PATH" ]; then
    exit 0
fi

if [ -n "$TMUX" ]; then
    exit 0
fi

if [ "$(grep -v '^#' "$TODO_PATH" | wc -l)" = "0" ]; then
    exit 0;
fi

# dash uses its own internal echo so force it to use the real one
/bin/echo -e "$BOLD""To do list:""$RESET"

sed '/^$/d' "$TODO_PATH" | grep -v '^#' | nl -w 1 -b t -s ') '



