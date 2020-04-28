#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   15/03/20 12:58

DOCKERFILES_PATH="$HOME"'/.scripts/.docker'

# Location of json file contain list of docker files
DOCKERJSON_PATH="$DOCKERFILES_PATH"'/docker.json'

# First program to start when entering docker container
PROC_ZERO='/bin/bash'

# The directory we are working in, set in `move_temp`
temp_dir=''

# Name of the user when we "log" in
user_name='ctfs'

# The location of the docker file and the name of the docker container
docker_file="$DOCKERFILES_PATH"'/ubuntu_19_10.Dockerfile'
docker_name='ubuntu19.10'

get_dockerfile () {
	cp "$docker_file" Dockerfile
	chmod 644 Dockerfile
}

copy_configs () {
	flags='--dereference --recursive'
	cp $flags ~/.bashrc bashrc
	cp $flags ~/.gdbinit gdbinit
	cp $flags ~/.config/radare2/ radare2
	cp $flags ~/.scripts scripts
	cp $flags ~/.tmux.conf tmux.conf
	cp $flags ~/.vim vim
}

clean_configs () {
	rm -rf bashrc
	rm -rf gdbinit
	rm -rf radare2
	rm -rf scripts
	rm -rf tmux.conf
	rm -rf vim
}

move_temp () {
	temp_dir="$(mktemp -d)"
	cd "$temp_dir"
}

dock_build () {
	docker \
		build \
		--tag="$user_name":"$docker_name" \
		.

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

dock_exec () {
	docker \
		exec \
		--interactive=true \
		--tty=true \
		"$user_name" \
		"$PROC_ZERO"
}

# We have multiple valid docker files, this is used to prompt the user to
# select their idea docker file.
arg_list () {
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

	docker_file="$(jq '.["'"$df"'"].docker_file' --raw-output "$DOCKERJSON_PATH")"
	docker_file="$DOCKERFILES_PATH"'/'"$docker_file"

	docker_name="$(jq '.["'"$df"'"].docker_name' --raw-output "$DOCKERJSON_PATH")"

}

get_cont_id () {
	if [ "$(docker ps | wc -l)" = 'XXX' ]; then
		printf 'There are no running containers!\n'
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

arg_parse () {
	while [ "$#" != '0' ]; do
		case "$1" in
			'-l'|'--list') arg_list ;;
			'-j'|'--join') docker_join ;;
			*) printf 'Invalid argument: %s\n' "$1" 1>&2
			   exit 1
		esac
		shift
	done
}

main () {
	move_temp
	copy_configs
	get_dockerfile
	dock_build
	clean_configs
	dock_exec
}

arg_parse $@
main $@



