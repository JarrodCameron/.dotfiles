#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   08/05/20 20:33

# Exit on non-zero return status
#set -e

. "$HOME"/.scripts/.docker/ops/shared.sh

DOCKERFILES_PATH="$HOME"'/.scripts/.docker'
DOCKERJSON_PATH="$DOCKERFILES_PATH"'/docker.json'

# We have multiple valid docker files, this is used to prompt the user to
# select their idea docker file.
choose_dockerfile () {
	local df="$(jq 'keys | .[]' --raw-output "$DOCKERJSON_PATH" \
	| fzf \
		--layout=reverse \
		--inline-info \
		--cycle \
		--margin=3 \
		--preview="$DOCKERFILES_PATH"'/display.sh {}')"

	if [ -z "$df" ]; then
		printf 'Invalid Dockerfile :(\n' >&2
		exit 1
	fi

	echo "$df"

}

# Returns the path to the Dockerfile given the name of the docker container
get_docker_file () {
	df="$1"
	docker_file="$(jq '.["'"$df"'"].docker_file' --raw-output "$DOCKERJSON_PATH")"
	echo "$DOCKERFILES_PATH"'/'"$docker_file"
}

# Returns the name of the Dockerfile given the name of the docker container
get_docker_name () {
	df="$1"
	jq '.["'"$df"'"].docker_name' --raw-output "$DOCKERJSON_PATH"
}

df="$(choose_dockerfile)"
if [ -z "$df" ]; then
	exit 1
fi

docker_file="$(get_docker_file "$df")"
docker_name="$(get_docker_name "$df")"

# Keep our current directory clean
cd "$(mktemp -d)"

cp "$docker_file" Dockerfile
chmod 644 Dockerfile

# TODO Store the name in the json file
docker_build "ctfs" "$docker_name"

# TODO Store the name in the json file
dock_id="$(docker_run "ctfs" "$docker_name")"

dock_img="$(docker inspect "$dock_id" | jq --raw-output '.[0].Image' | cut -d ':' -f 2)"

echo 'Container ID:' "$dock_id"
echo 'Image ID:' "$dock_img"

copy_configs "$dock_id"

docker_exec "$dock_id" "$PROC_ZERO"
