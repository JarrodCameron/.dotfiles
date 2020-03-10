#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   17/12/19  7:39

# Script to simply print the amount of battery being used

full="$(cat /sys/class/power_supply/BAT0/charge_full)"
curr="$(cat /sys/class/power_supply/BAT0/charge_now)"
ratio="$(echo "100 * "$curr" / "$full"" | bc)%"
status="$(cat /sys/class/power_supply/BAT0/status)"

if [ "$status" = "Discharging" ]; then
    printf "<fc=#ff0000>Bat: %s</fc>" "$ratio"
else
    printf "<fc=#00ff00>Cha: %s</fc>" "$ratio"
fi


