#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   25/03/20  9:37

DOCKERFILES_PATH="$HOME"'/.scripts/.docker'
DOCKERJSON_PATH="$DOCKERFILES_PATH"'/docker.json'

df="$1"

docker_file="$(jq '.["'"$df"'"].docker_file' --raw-output "$DOCKERJSON_PATH")"
docker_file="$DOCKERFILES_PATH"'/'"$docker_file"

bat --style='plain' --color='always' "$DOCKERFILE_PATH"'/'"$docker_file"
