#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   05/02/20 20:28

search_line="$(man -k '.' | fzf --layout=reverse --margin=3 --inline-info --cycle)"

if [ -z "$search_line" ]; then
    printf "Please select valid man page...\n" 1>&2
    exit 1
fi

man_page="$(echo "$search_line" | awk '{print $2, $1}' | sed 's/[()]//g')"

# For better man pages
export MANWIDTH=80
export MANPAGER="/bin/sh -c \"col -b | vim --not-a-term -c 'set ft=man ts=8 nomod nolist noma' -\""

man $man_page

