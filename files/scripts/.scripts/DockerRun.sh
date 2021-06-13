#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   29/03/21 19:18

# Exit on non-zero return status
set -e

fzf_wrapper () {
	fzf \
		--layout=reverse \
		--inline-info \
		--cycle \
		--margin=3
}

docker_run () {
	image_id="$1"
	docker \
		run \
		--rm \
		--detach=true \
		-v "$(pwd)":/root/pwd \
		--cap-add=SYS_PTRACE \
		--security-opt seccomp=unconfined \
		--interactive=true \
		"$image_id"
}

docker_exec () {
	cont="$1"
	proc="$2"
	docker \
		exec \
		"$cont" \
		$proc
}

docker_send () {
	cont="$1"
	file="$2"
	dest="$3"
	docker cp --follow-link=true "$file" "$cont":"$dest"
}

line="$(docker images | tail -n +2 | fzf_wrapper)"

if [ -z "$line" ]; then
	echo 'ERROR: No image select!' >&2
	exit 0
fi

image_id="$(echo "$line" | awk '{print $3}')"

container_id="$(docker_run "$image_id")"

docker_exec "$container_id" 'mkdir -p /root/.config'
docker_exec "$container_id" 'mkdir -p /root/.config/radare2/'

{
	echo '.bashrc'
	echo '.gdbinit'
	echo '.config/radare2/radare2rc'
	echo '.scripts'
	echo '.tmux.conf'
	echo '.vim'
} | while read name
do
	docker_send "$container_id" "$HOME"/"$name" /root/"$name"
done


# So that gdb can use the right pwndbg
docker_exec \
	"$container_id" \
	"sed -i s#/usr/share/pwndbg/gdbinit.py#/root/tools/pwndbg/gdbinit.py#g /root/.gdbinit"

