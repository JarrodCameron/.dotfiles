#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   04/09/19  7:56

# TODO:
# - memort
# - processors
# - wifi battery
# - volume
# - date

count=0

get_date () {
    printf "%s" "$(date '+%A, %B, %d-%m-%Y %I:%M %p')"
}

while [ "1" ]
do

    title="$(get_date)"

    xsetroot -name "$title"

    echo $title

    sleep 1
    count=$((count+1))
done



