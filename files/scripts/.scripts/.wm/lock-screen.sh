#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   16/11/20 19:21

# Exit on non-zero return status
set -e

BLUR="0x4"

t="$(mktemp -d)"

in="$t"'/in.png'
out="$t"'/out.png'

scrot "$in"

notify-send -t 4000 'Converting Image' &

convert "$in" -gaussian-blur "$BLUR" "$out"

i3lock --nofork -i "$out"

rm -rf "$t" &
