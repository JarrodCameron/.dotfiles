#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   27/03/20 11:10

# Exit on non-zero return status
set -e

if [ "$#" != '2' ]; then
	printf 'Usage: ./upload.sh <device> <file>\n' >&2
	exit 1
fi

#dev='/dev/ttyACM0'
#file='test.hex'
dev="$1"
file="$2"

echo $dev
echo $dev
echo $dev

echo $file
echo $file
echo $file

avrdude \
	-v \
	-C "$HOME"'/.config/avrdude/avrdude.conf' \
	-c wiring \
	-p m2560 \
	-P "$dev" \
	-b 115200 \
	-D \
	-U flash:w:"$file":i
