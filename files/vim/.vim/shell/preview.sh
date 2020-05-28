#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   06/05/20 20:02

# Exit on non-zero return status
set -e

if [ "$#" != '2' ]; then
	echo 'Usage: preview.sh <file> <line#>' >&2
	exit 1
fi

if [ -z "$FZF_PREVIEW_LINES" ]; then
	echo 'FZF_PREVIEW_LINES is not defined!' >&2
	exit 2
fi

file="$1"
line="$2"

start="$(awk 'END {
	line_num = '"$line"'
	max_lines = '"$FZF_PREVIEW_LINES"'

	offset = max_lines / 2
	offset -= offset % 1

	start = line_num - offset
	if (start < 0)
		start = 0

	printf "%d", start
} ' </dev/null)"

bat --color=always -H "$line" -r "$start": "$file"



