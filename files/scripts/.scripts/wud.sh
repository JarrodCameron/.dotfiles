#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   21/04/20 22:10

# Loop until a process has finished. Once it has finished run a command

# Exit on non-zero return status
set -e

DELAY='1'

if [ "$#" -lt '2' ]; then
	printf 'Usage: wud <pid> <cmd...>\n' >&2
	exit 1
fi


pid="$1"

shift
cmd="$@"

if [ ! -d '/proc/'"$pid" ]; then
	printf 'Process %s does not exist!\n' "$pid" >&2
	exit 1
fi

echo $cmd

while [ -d '/proc/'"$pid" ]; do
	sleep "$DELAY"
done

eval "$cmd"



