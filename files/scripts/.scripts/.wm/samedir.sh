#!/bin/sh

# Author: Jarrod Cameron (z5210220)

[ -z "$TERMINAL" ] && TERMINAL="$(which termite)"

# More information about window properties can be found at:
#  https://standards.freedesktop.org/wm-spec/wm-spec-latest.html

# The window ID of the currently active window
win_id="$(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/ {print $NF}')"

# If no window is in focus $win_id should be an empty string, if so then exit
[ -n "$win_id" ] || "$TERMINAL; exit 1"

# This is the process ID of the terminal (not the shell)
term_pid="$(xprop -id "$win_id" | awk '/_NET_WM_PID\(CARDINAL\)/ {print $NF}')"

# Process ID of the shell
# NOTE: Viewing the cwd of the terminal requires root privileges
shell_pid="$(ps --ppid $term_pid | awk '/bash|sh/ {print $1}')"

# The shells current directory
# NOTE: If user is currently in a symlink, terminal is open in original location
path="$(readlink /proc/"$shell_pid"/cwd)"

cd "$path"
"$TERMINAL"