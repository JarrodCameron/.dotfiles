#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   29/03/21 20:11

# Exit on non-zero return status
set -e

docker ps | tail -n +2 | awk '{print $1}' | while read id
do
	docker kill "$id" >/dev/null
done

docker system prune --force
