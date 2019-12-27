#!/usr/bin/env bash

# Author: Jarrod Cameron (z5210220)
# Date:   18/12/19  8:49

# Initialises the screen layout and the bars for each screen. The bar being
# used is xmobar

eval $(xrandr --query | awk '
BEGIN {
  FS=" ";
  count=0
}
/ connected/ {
  printf "output_%d=%s ;\n", count, $1
  count++
}
END {
  printf "n_output=%d ;\n", count
}')

primary="$output_0"
secondary="$output_1"
max_screen=''

if [ -z "$primary" ]; then
    printf 'No screens...?\n' >&2
    exit 1
elif [ -z "$secondary" ]; then
    # Single screen
    max_screen=0
else
    # Dual screen
    xrandr --output "$secondary" --auto --right-of "$primary"
    max_screen=1
fi

for num in `seq 0 $max_screen`; do
    rm -rf ~/.xmobar
    xmobar -x "$num" &
done

