#!/usr/bin/env bash

# Author: Jarrod Cameron (z5210220)
# Date:   24/12/19 13:41

SESSION="radare2_debug"
BOT_HEIGHT=7

if [ -z "$1" ]; then
    printf "Usage: bash d2_spawn.sh </path/to/a.out>\n" >&2
    exit 1
fi

prog_name="$1"
prog_tty="$(tty)"
cmd="radare2 -R stdio=${prog_tty} -d ${prog_name}"

tmux split-window -t "${SESSION}" "${cmd}"

pane1="$(tmux list-panes -t "${SESSION}" | awk -F':' 'NR==1{print $1}')"
pane2="$((pane1+1))"

# radare2 at the top, rarun2 at the bottom
tmux swap-pane -s "${pane1}" -t "${pane2}"

# Focus bottom pane
tmux last-pane -t "${SESSION}"

# Resize bottom pane
tmux resize-pane -y "${BOT_HEIGHT}" -t "${SESSION}"

# Focus top pane (radare2)
tmux last-pane -t "${SESSION}"

# Call `rarun2'
rarun2 -t $prog_name



