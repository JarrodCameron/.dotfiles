#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   04/05/20 11:27

# Exit on non-zero return status
set -e

# Shared directory between host and container
SHARED_DIR="$HOME"'/repos/ctfsolns'

# The process that is run when entering the container
PROC_ZERO='/bin/bash'

# Execute the "$proc" process in the "$cont" container
docker_exec () {
	cont="$1"
	proc="$2"
	docker \
		exec \
		--interactive=true \
		--tty=true \
		"$cont" \
		$proc
}

docker_build () {
	user="$1"
	cont="$2"
	docker \
		build \
		--tag="$user":"$cont" \
		.
}

docker_run () {
	user="$1"
	cont="$2"
	docker \
		run \
		--rm \
		--detach=true \
		-v "$SHARED_DIR":/pwd \
		--cap-add=SYS_PTRACE \
		--security-opt seccomp=unconfined \
		--name "$user" \
		--interactive=true \
		"$user":"$cont"
}

# Send a copy of a file to the given container
docker_send () {
	cont="$1"
	file="$2"
	dest="$3"
	docker cp --follow-link=true "$file" "$cont":"$dest"
}

copy_configs () {
	id="$1"

	# To prevent docker-cp from complaining
	docker_exec "$id" 'mkdir -p /root/.config'

	docker_send "$id" "$HOME"/.bashrc /root/.bashrc
	docker_send "$id" "$HOME"/.gdbinit /root/.gdbinit
	docker_send "$id" "$HOME"/.config/radare2/ /root/.config/radare2/
	docker_send "$id" "$HOME"/.scripts /root/.scripts
	docker_send "$id" "$HOME"/.tmux.conf /root/.tmux.conf
	docker_send "$id" "$HOME"/.vim /root/.vim
}

fzf_wrapper () {
	fzf \
		--layout=reverse \
		--inline-info \
		--cycle \
		--margin=3
}

get_cont_id () {
	if [ "$(docker ps | wc -l)" = '1' ]; then
		printf 'There are no running containers!\n' >&2
	elif [ "$(docker ps | wc -l)" = '2' ]; then
		# Only one container running
		docker ps | tail -n +2 | awk '{print $1}'
	else
		ret="$(docker ps | tail -n +2 | fzf_wrapper)"
		if [ -z "$ret" ]; then
			printf 'Please choose a container\n' >&2
		else
			echo "$ret" | awk '{print $1}'
		fi
	fi
}

get_img_id () {
	if [ "$(docker images | wc -l)" = '1' ]; then
		printf 'There are no running images!\n' >&2
	elif [ "$(docker images | wc -l)" = '2' ]; then
		# Only one container running
		docker images | tail -n +2 | awk '{print $3}'
	else
		ret="$(docker images | tail -n +2 | fzf_wrapper)"
		if [ -z "$ret" ]; then
			printf 'Please choose an image\n' >&2
		else
			echo "$ret" | awk '{print $3}'
		fi
	fi
}

