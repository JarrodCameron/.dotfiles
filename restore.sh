#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   03/03/20 19:55

DB='dotfiles.json'

FILES_PATH="$HOME"'/.dotfiles/files'

# 0 -> Prompt the user if they want to remove the file if it already exists
# 1 -> Remove the file if it exists
force_remove='0'

# Check if the name is actually in the json file
check_dname () {
	name="$1"
	echo $name
	if [ "$(jq '.["'"$name"'"]' "$DB")" = 'null' ]; then
		printf 'Error: "%s" is not in the json file!\n' "$name" 1>&2
		exit 1
	fi
}

# Check if the file is actually there
check_fname () {
	name="$1"
	file="$2"
	if [ ! -d "$FILES_PATH"'/'"$name" ]; then
		printf 'Error: "%s" is not backed up!\n' "$name" 1>&2
		exit 1
	fi

	if [ ! -e "$FILES_PATH"'/'"$name"'/'"$file" ]; then
		printf 'Error: "%s" is missing!\n' "$name" 1>&2
		exit 1
	fi
}

# Remove the file if it already exists somewhere in disk
rm_dfile () {
	path="$1"
	file="$2"
	name="$3"
	status=''

	full_path="$path"'/'"$file"

	if [ "$force_remove" = '1' ]; then
		rm -rf "$full_path"
		return
	fi

	if [ -e "$full_path" ] || [ -h "$full_path" ]; then
		printf 'Do you want to remove "%s"? [Y/n] ' "$name"
		read status
		if [ -z "$status" ] || [ "$status" = 'Y' ] || [ "$status" = 'y' ]; then
			rm -rf "$full_path"
		else
			printf 'Exiting...\n'
			exit 1
		fi
	fi

}

# Return the real name of the dot file (e.g. .gdbinit)
get_dfile () {
	name="$1"
	jq --raw-output '.["'"$name"'"].file' "$DB"
}

# Return the real path of the dot file (e.g. .gdbinit)
get_dpath () {
	name="$1"
	path="$(jq --raw-output '.["'"$name"'"].path' "$DB")"

	# eval() will glob that path
	eval echo "$path"
}

init_path () {
	path="$1"
	mkdir -p "$path"
}

init_link () {
	name="$1"
	file="$2"
	path="$3"

	# The real_path is the path of the original file, backed up by git
	# The fake_path is the file path of the link
	real_path="$FILES_PATH"'/'"$name"'/'"$file"
	fake_path="$path"'/'"$file"

	ln -s "$real_path" "$fake_path"
	if [ "$?" != '0' ]; then
		printf 'Error: Creating symlink from "%s" to "%s"\n' "$real_path" "$fake_path"
		exit 1
	fi
}

# There is an optional paramater `init` which will be eval()'d after the
# symlink is created. If the entry doesn't have an `init` command just quit
run_init () {
	name="$1"

	cmd="$(jq '.["'"$name"'"].init' --raw-output "$DB")"
	if [ "$cmd" != 'null' ]; then
		eval "$cmd"
	fi
}

do_restore () {
	dname="$1"
	dfile="$(get_dfile "$dname")"
	dpath="$(get_dpath "$dname")"
	check_fname "$dname" "$dfile"
	rm_dfile "$dpath" "$dfile" "$dname"
	init_path "$dpath"
	init_link "$dname" "$dfile" "$dpath"
	run_init "$dname"
}

handle_args () {
	while [ "$#" != '0' ]; do
		arg="$1"
		shift

		case "$arg" in
			'-f'|'--force') force_remove='1' ;;
		esac

	done
}

handle_args $@

for dotfile in $(jq 'keys | .[]' --raw-output "$DB")
do
	do_restore "$dotfile"
done
