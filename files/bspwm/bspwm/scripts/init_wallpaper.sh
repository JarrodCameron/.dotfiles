#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   09/02/20 16:51

# To convert image.jpg to a png:
# ffmpeg -s 1920x1080 -i image.jpg image.png

# Set a random wallpaper for each screen. This script is usually called on
# startup by the window manager

num_screens="$(xrandr --query | grep ' connected' | wc -l)"

images="$(ls ~/images/wallpapers/*.png | sort -R | head -n "$num_screens" | while read line
do
    printf " %s" "$line"
done)"

feh --bg-center $images






