#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   28/04/21  9:07

# Exit on non-zero return status
set -e

if [ "$#" != 2 ]; then
	echo 'Usage:' "$0" '<input image> <output image>' >&2
	exit 1
fi

i="$1"
o="$2"

if [ ! -e "$i" ]; then
	echo 'ERROR: input file does not exist!' >&2
	exit 1
fi

if [ -e "$o" ]; then
	echo 'ERROR: output file already exists!' >&2
	exit 1
fi

ffmpeg -i "$i" -vf scale=1920:1080 "$o"



