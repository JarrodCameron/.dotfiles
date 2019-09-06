#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   04/09/19  7:56

# TODO:
# - memort
# - processors
# - wifi
# - battery @ /sys/class/power_supply/BAT0/*

count=0

get_date () {
    printf "%s" "$(date '+%A, %B, %d-%m-%Y %I:%M %p')"
}

get_vol () {
    # NOTE: Only tested with single sink
    local left="$(pacmd list-sinks | awk -F' ' '/volume: front/ {print $5}' | head -n1)"
    local right="$(pacmd list-sinks | awk -F' ' '/volume: front/ {print $12}' | head -n1)"

    # Trim last char (the `%')
    left=${left%?}
    right=${right%?}

    printf "Vol: %s" "$(echo "($left + $right) / 2" | bc )"
}

while [ "1" ]
do

    title="$(get_date)"

    title="$(get_vol)"" | $title"

    xsetroot -name "$title"

    echo $title

    sleep 1
    count=$((count+1))
done



