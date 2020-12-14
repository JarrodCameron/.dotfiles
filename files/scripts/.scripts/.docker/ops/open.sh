#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   06/06/20 13:35

# Exit on non-zero return status
set -e

. "$HOME"/.scripts/.docker/ops/shared.sh

MOVE_CONFIGS=0

while [ "$#" != '0' ]; do
	arg="$1"
	shift
	case "$arg" in
		'-c'|'--config') MOVE_CONFIGS=1 ;;
	esac
done

if [ "$(docker images | wc -l)" = '1' ]; then
	printf 'There are no docker images\n' >&2
	printf "Use \`dock.sh -b' to creat a docker image\n" >&2
	exit 1
fi
docker_image="$(docker images | tail -n +2 | fzf_wrapper)"
if [ -z "$docker_image" ]; then
	printf 'Invalid docker image!\n'
	exit 1
fi

user_name="$(echo $docker_image | awk '{print $1}' | awk -F'/' '{print $NF}')"
docker_name="$(echo $docker_image | awk '{print $2}')"

digest="$(docker_run "$user_name" "$docker_name")"
if [ -z "$digest" ]; then
	# Container is already running
	exit 1
fi

if [ "$MOVE_CONFIGS" = '1' ]; then
	copy_configs "$digest"
fi

docker_exec "$digest" "$PROC_ZERO"




