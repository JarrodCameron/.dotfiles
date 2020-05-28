#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   04/05/20 12:10

# Exit on non-zero return status
#set -e

. "$HOME"/.scripts/.docker/ops/shared.sh

usage () {
	printf 'dock.sh --kill\n'
}

cont="$(get_cont_id)"
if [ -z "$cont" ]; then
	printf 'Invalid container to kill\n' >&2
	exit 1
fi

docker kill "$cont"



