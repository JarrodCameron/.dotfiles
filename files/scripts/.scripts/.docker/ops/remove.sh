#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   10/05/20 20:18

# Exit on non-zero return status
set -e

. "$HOME"/.scripts/.docker/ops/shared.sh

id="$(get_img_id)"
if [ -z "$id" ]; then
	printf ':(\n'
	exit 1
fi

docker rmi --force=true "$id"



