#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   23/01/21  8:09

# Exit on non-zero return status
set -e

LOG_DIR='.tmux_logs'

usage ()
{
	echo 'Usage: tmux_log.sh <option>'
	echo 'Options:'
	echo '-i, --init'
	echo '    Start up the tmux session'
	echo ''
	echo '-r, --replay replayID'
	echo '    Replay the tmux session'
	echo ''
	echo '-h, --help'
	echo '    Display this help'
}

tmux_init ()
{
	if [ ! -e "$LOG_DIR" ]; then
		mkdir -p "$LOG_DIR"
	fi
	s="$(date '+%s')"

	script_file="$LOG_DIR"'/typescript|'"$s"
	timing_file="$LOG_DIR"'/timing|'"$s"

	script --command 'tmux' --log-timing "$timing_file" "$script_file"
}

tmux_replay ()
{
	if [ ! -e "$LOG_DIR" ] || [ "$(ls "$LOG_DIR" | wc -l)" = '0' ]; then
		echo 'There are not scripts!'
		exit 1
	fi

	t="$(ls .tmux_logs/ | awk -F'|' '{print $2}' | sort -u | fzf)"

	timing_file="$LOG_DIR"'/timing|'"$t"
	script_file="$LOG_DIR"'/typescript|'"$t"

	echo '+---------------------+'
	sleep 0.75
	echo '| Pause: Control+s    |'
	sleep 1
	echo '| Continue: Control+q |'
	sleep 1
	echo '+---------------------+'
	sleep 2

	scriptreplay -t "$timing_file" "$script_file" -m 0.01
}

while true
do
	arg="$1"

	case "$arg"
	in
		'-i'|'--init') tmux_init $@ ; exit ;;
		'-r'|'--replay') tmux_replay $@ ; exit ;;
		'-h'|'--help') usage ; exit ;;
		*) usage >&2 ; exit ;;
	esac

	shift 1

done



