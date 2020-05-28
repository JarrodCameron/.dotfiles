#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   15/03/20 12:58

# Where to save/load docker images
DOCKER_IMAGES="$HOME"'/.cache/docker_images'

# First program to start when entering docker container
PROC_ZERO='/bin/bash'

# Name of the user when we "log" in
# XXX NOTE: should not contain spaces
user_name='ctfs'

# The location of the docker file and the name of the docker container
docker_name='ubuntu19.10'

docker_exec () {
	user_name="$1"
	docker \
		exec \
		--interactive=true \
		--tty=true \
		"$user_name" \
		"$PROC_ZERO"
}

fzf_wrapper () {
	fzf \
		--layout=reverse \
		--inline-info \
		--cycle \
		--margin=3
}

get_cont_id () {
	if [ "$(docker ps | wc -l)" = 'XXX' ]; then
		printf 'There are no running containers!\n' >&2
	elif [ "$(docker ps | wc -l)" = '2' ]; then
		# Only on container running
		docker ps | tail -n +2 | awk '{print $1}'
	else
		printf 'TODO: fzf for many containers (ENOSYS)\n' >&2
	fi
}

# Join to an already-running docker session (good for multi monitors)
docker_join () {
	cont_id="$(get_cont_id)"
	if [ -z "$cont_id" ]; then
		exit 1
	fi

	docker \
		exec \
		--interactive=true \
		--tty=true \
		"$cont_id" \
		"$PROC_ZERO"

	# No reason to stay
	exit 0
}

docker_save () {
	mkdir -p "$DOCKER_IMAGES"
	cont_id="$(get_cont_id)"
	if [ -z "$cont_id" ]; then
		exit 1
	fi

	docker_image="$(docker ps | awk '/'"$cont_id"'/ {print $2}')"

	new_image="$DOCKER_IMAGES"'/'"$docker_image"'.tar'

	if [ -e "$new_image" ]; then
		printf '"%s" already exists, would you like to replace it? [Y/n] ' "$docker_image"
		read ans
		if [ -n "$ans" ] && [ "$ans" != 'y' ] && [ "$ans" != 'Y' ]; then
			exit 0
		fi
	fi

	printf 'Saving: "%s"\n' "$docker_image"
	docker save "$docker_image" --output="$new_image"

	exit 0
}

docker_run () {
	user_name="$1"
	docker_name="$2"
	docker \
		run \
		--rm \
		--detach=true \
		-v "$(pwd)":/pwd \
		--cap-add=SYS_PTRACE \
		--security-opt seccomp=unconfined \
		--name "$user_name" \
		--interactive=true \
		"$user_name":"$docker_name"
}

docker_open () {
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

	user_name="$(echo $docker_image | awk '{print $1}')"
	docker_name="$(echo $docker_image | awk '{print $2}')"

	digest="$(docker_run "$user_name" "$docker_name")"
	if [ -z "$digest" ]; then
		# Container is already running
		exit 1
	fi

	docker_exec "$digest"

	exit 0
}

docker_help () {
	printf 'dock.sh {-l|--list}\n'
	printf '  Choose from one of the docker images.\n'

	printf 'dock.sh {-j|--join}\n'
	printf '  Join a currently running docker session.\n'

	printf 'dock.sh {-s|--save}\n'
	printf '  Save a currently running docker session.\n'

	printf 'dock.sh {-h|--help}\n'
	printf '  Display this help.\n'
}

arg_parse () {
	while [ "$#" != '0' ]; do
		arg="$1"
		shift
		case "$arg" in
			'-j'|'--join') docker_join ;;
			'-s'|'--save') docker_save ;; # TODO Remove this crap
			'-o'|'--open') docker_open ;;
			'-h'|'--help') docker_help ; exit 0 ;;
			'-r'|'--remove') ~/.scripts/.docker/ops/remove.sh "$@" ; exit 0 ;;
			'-b'|'--build') ~/.scripts/.docker/ops/build.sh "$@" ; exit 0 ;;
			'-m'|'--move') ~/.scripts/.docker/ops/move.sh "$@" ; exit 0 ;;
			'-k'|'--kill') ~/.scripts/.docker/ops/kill.sh "$@" ; exit 0 ;;
			*) printf 'Invalid argument: "%s"\n' "$1" 1>&2
			   docker_help 1>&2
			   exit 1
		esac
	done
}

arg_parse $@



