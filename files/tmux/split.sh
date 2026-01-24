#!/bin/sh

die () {
	echo "$1" 2>&1
	exit 1
}

[ "$#" -ne 1 ] && die "Usage: ./$0 [--horizontal|--vertical]"

arg="$1"
[ "$arg" != '--horizontal' ] && [ "$arg" != '--vertical' ] && die "[!] Invalid arg: \"$1\""

[ -z "$TMUX" ] && die '[!] Must run inside tmux session!'

pane_pid="$(tmux display-message -p -F "#{pane_pid}")"
pane_path="$(realpath "/proc/$pane_pid/cwd")"

[ "$arg" = '--horizontal' ] && tmux split-window -c "$pane_path" -v
[ "$arg" = '--vertical' ] && tmux split-window -c "$pane_path" -h

# This prevents tmux from throwing errors
exit 0
