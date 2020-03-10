#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   05/02/20 19:44

# Prompt the user with a list of all possible man pages. After the user
# selects one spawn a new terminal with that man page open.

# If running `man -k '.'` returns "nothing appropriate result" or an outdated
# list of man pages there are two solutions:
# 1. Run `mandb` as root
# 2. Edit `/usr/lib/systemd/system/man-db.timer` and update "AccuracySec=12h"
#    to "AccuracySec=6h" for updated fours times a day.

COLORS='-fn monospace:size=14 -nb #282828 -nf #ebdbb2 -sf #1d2021 -sb #689d68'

search_line="$(man -k '.' | dmenu -i -l "20" -p "man: " $COLORS)"

# I should also check if the man page is valid but that takes too long
if [ -z "$search_line" ]; then
    printf "Please select valid man page...\n" 1>&2
    exit 1
fi

man_page="$(echo "$search_line" | awk '{print $2, $1}' | sed 's/[()]//g')"

# For better man pages
export MANWIDTH=80
export MANPAGER="/bin/sh -c \"col -b | vim --not-a-term -c 'set ft=man ts=8 nomod nolist noma' -\""

termite -e "man $man_page"

