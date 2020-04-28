#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   24/04/20 22:19

# Exit on non-zero return status
set -e

if [ -z "$1" ]; then
	echo 'Usage: sudo <cmd>' >&2
	exit 1
fi

su -c "$@"


