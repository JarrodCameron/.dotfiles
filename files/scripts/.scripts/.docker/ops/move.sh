#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   04/05/20 11:24

# Exit on non-zero return status
#set -e

. "$HOME"/.scripts/.docker/ops/shared.sh

usage () {
	printf 'dock.sh --move <args>\n'
	printf '  Move file(s) into a given container\n'
	printf '\n'
	printf 'arg={-c|--configs}\n'
	printf '  Copy config files into a given container\n'
}

move_file () {
	file="$1"

	if [ ! -e "$file" ]; then
		usage >&2
		exit 1
	fi

	cont="$(get_cont_id)"
	if [ -z "$cont" ]; then
		printf 'Invalid container\n' >&2
		exit 1
	fi

	dest="$(docker_exec "$cont" 'find /' | fzf_wrapper | tr -d '\r')"
	if [ -z "$dest" ]; then
		printf 'Invalid destination\n' >&2
		exit 1
	fi

	docker cp "$file" "$cont":"$dest"

	printf '%s -> %s:%s\n' "$file" "$cont" "$dest"

}

move_configs () {

	cont="$(get_cont_id)"
	if [ -z "$cont" ]; then
		printf 'Invalid container\n' >&2
		exit 1
	fi

	printf 'Moving configs...\n'

	copy_configs "$cont"

}

if [ "$#" = '0' ]; then
	usage >&2
	exit 1
fi

while [ "$#" != '0' ]; do
	arg="$1"
	shift
	case "$arg" in
		'-c'|'--config') move_configs ; exit 0 ;;
		'-h'|'--help') usage >&2 ; exit 0 ;;
		*) move_file "$1" ; exit 0 ;;
	esac
done
