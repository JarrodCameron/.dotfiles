#!/usr/bin/env bash

# Author: Jarrod Cameron (z5210220)

function get_template () {
  ret="wallpaper"
  ret+="$(printf "%03d" "$index")"
  ret+=".png"
  echo $ret
}

old_imgs="$(ls | grep -v "wallpaper[0-9][0-9][0-9].png" | grep -v "script.sh")"

index=1
for img in $old_imgs; do
  template=$(get_template $index)

  # Get the next free template
  while [ "$(ls | grep "$template")" ]; do
    index="$(echo "$index + 1" | bc)"
    template=$(get_template $index)
  done

  ffmpeg -i "$img" -vf scale=1920:1080 "$template" 
  rm "$img"

  index="$(echo "$index + 1" | bc)"
done
