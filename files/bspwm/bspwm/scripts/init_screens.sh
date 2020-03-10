#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   04/02/20 21:44

eval $(xrandr --query | awk '
BEGIN {
  count=0
}
/ connected/ {
  printf "monitor_%d=%s ;\n", count, $1
  count++
}')

primary="$monitor_0"
secondary="$monitor_1"

if [ -z "$primary" ]; then
    printf 'No screens...?\n' >&2
    exit 1
elif [ -z "$secondary" ]; then
    # Single monitor
    bspc monitor -d I II III IV V VI VII VIII IX X
else
    # Dual screen
    xrandr --output "$secondary" --auto --right-of "$primary"
    bspc monitor eDP1 -d I II III IV V
    bspc monitor DP1 -d VI VII VIII IX X
fi

