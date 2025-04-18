#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   03/03/20 19:55

CONFIG_FILE="$(dirname "$(realpath "$0")")/dotfiles.json"
FILES_PATH="$(dirname "$(realpath "$0")")/files"

die () {
	echo "[ERROR] $1" 1>&2
	exit 1
}

# Remove the file if it already exists somewhere in disk
remove_existing_symlink () {
	path="$1"
	file="$2"
	name="$3"
	status=''

	full_path="$path"'/'"$file"

	if [ -e "$full_path" ] || [ -h "$full_path" ]; then
		printf 'Do you want to remove "%s"? [Y/n] ' "$name"
		read status
		if [ -z "$status" ] || [ "$status" = 'Y' ] || [ "$status" = 'y' ]; then
			rm -rf "$full_path"
		else
			die 'Exiting...'
		fi
	fi

}

do_restore () {
	dname="$1"

	dfile="$(jq -r --arg key "$dname" '.[$key].file' "$CONFIG_FILE")"
	dpath="$(jq -r --arg key "$dname" '.[$key].path' "$CONFIG_FILE" | sed "s#^~#$HOME#g")"

	[ ! -d "$FILES_PATH"'/'"$dname" ] && die "\"$dname\" is not backed up!'"
	[ ! -e "$FILES_PATH"'/'"$dname"'/'"$dfile" ] && die "\"$dname\" is missing!"

	remove_existing_symlink "$dpath" "$dfile" "$dname"

	mkdir -p "$dpath"


	real_path="$FILES_PATH"'/'"$dname"'/'"$dfile"
	fake_path="$dpath"'/'"$dfile"
	ln -s "$real_path" "$fake_path"
	[ "$?" != '0' ] && "Creating symlink from \"$real_path\" to \"$fake_path\""
}

for dotfile in $(jq 'keys | .[]' --raw-output "$CONFIG_FILE")
do
	do_restore "$dotfile"
done
