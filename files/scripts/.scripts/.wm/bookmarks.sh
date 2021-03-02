#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   21/02/21 10:49

# The contents of the bookmark file is
# name1,url1,browser1
# name2,url2,browser2
# name3,url3,browser3
# ...
# nameN,urlN,browserN

BOOKMARKS_DIR="$HOME"'/.cache/bookmarks/'
BOOKMARKS_FILE="$BOOKMARKS_DIR"'bookmarks.csv'

# Simple dmenu wrapper
run_dmenu ()
{
	height="$1"
	prompt="$2"
	IFS=''
	while read line
	do
		printf "%s\n" "$line"
	done | dmenu -i -l "$height" -p "$prompt" \
			-fn 'monospace:size=10' \
			-nb "#282828" \
			-nf "#ebdbb2" \
			-sf "#1d2021" \
			-sb "#689d68"
}

encode ()
{
	/bin/echo -n "$1" | base64 | tr -d '\n'
}

decode ()
{
	echo "$1" | base64 -d
}

decode_name ()
{
	echo "$1" | awk -F',' '{print $1}' | base64 -d
}

decode_url ()
{
	echo "$1" | awk -F',' '{print $2}' | base64 -d
}

decode_browser ()
{
	echo "$1" | awk -F',' '{print $3}' | base64 -d
}

die ()
{
	echo "$1" >&2
	exit 1
}

# Prints each name in the bookmarks file after decoding the string
print_names ()
{
	{
		cat "$BOOKMARKS_FILE" | awk -F',' '{print $1}' | while read name
		do
			decode "$name"
			echo
		done
	} | sort
}

intro_prompt ()
{
	height="$(wc -l < "$BOOKMARKS_FILE")"
	height="$((height+3))"
	{
		print_names
		echo '[Insert]'
		echo '[Modify]'
		echo '[Remove]'
	} | run_dmenu "$height" 'Open bookmark:'
}

user_input ()
{
	prompt="$1"
	run_dmenu 0 "$prompt" < /dev/null
}

get_browser ()
{
	printf 'firefox
firefox --new-window
firefox --private-window
brave
' | run_dmenu 4 'Bookmark browser:'
}

# Returns an entry in the booksmarks file given the name of the bookmark
get_entry ()
{
	name="$(encode "$1")"
	awk -F',' '{
		if ("'"$name"'" == $1)
			print $0
	}' "$BOOKMARKS_FILE"
}

do_insert ()
{
	bm_name="$(user_input 'Bookmark name:')"
	[ -z "$bm_name" ] && die 'ERROR: Invalid name'

	[ -n "$(get_entry "$bm_name")" ] && die 'ERROR: Bookmark already exists'

	bm_url="$(user_input 'Bookmark url:')"
	[ -z "$bm_url" ] && die 'ERROR: Invalid URL'

	bm_browser="$(get_browser)"
	[ -z "$bm_browser" ] && die 'ERROR: Invalid browser'

	{
		encode "$bm_name"
		/bin/echo -n ','
		encode "$bm_url"
		/bin/echo -n ','
		encode "$bm_browser"
		echo
	} >> "$BOOKMARKS_FILE"
}

modify_browser ()
{
	entry="$1"

	new_browser="$(get_browser)"
	[ -z "$new_browser" ] && die 'ERROR: Invalid browser chosen'

	old_name="$(decode_name "$entry")"
	old_url="$(decode_url "$entry")"

	tmp="$(mktemp)"
	grep --fixed-strings -v "$entry" "$BOOKMARKS_FILE" > "$tmp"
	{
		encode "$old_name"
		/bin/echo -n ','
		encode "$old_url"
		/bin/echo -n ','
		encode "$new_browser"
		echo
	} >> "$tmp"
	mv "$tmp" "$BOOKMARKS_FILE"
}

modify_name ()
{
	entry="$1"

	new_name="$(user_input 'Bookmark name:')"
	[ -z "$new_name" ] && die 'ERROR: Invalid name chosen'

	[ -n "$(get_entry "$new_name")" ] && die 'ERROR: Bookmark already exists'

	old_browser="$(decode_browser "$entry")"
	old_url="$(decode_url "$entry")"

	tmp="$(mktemp)"
	grep --fixed-strings -v "$entry" "$BOOKMARKS_FILE" > "$tmp"
	{
		encode "$new_name"
		/bin/echo -n ','
		encode "$old_url"
		/bin/echo -n ','
		encode "$old_browser"
		echo
	} >> "$tmp"
	mv "$tmp" "$BOOKMARKS_FILE"
}

modify_url ()
{
	entry="$1"

	new_url="$(user_input 'Bookmark url:')"
	[ -z "$new_url" ] && die 'ERROR: Invalid URL'

	old_browser="$(decode_browser "$entry")"
	old_name="$(decode_name "$entry")"

	tmp="$(mktemp)"
	grep --fixed-strings -v "$entry" "$BOOKMARKS_FILE" > "$tmp"
	{
		encode "$old_name"
		/bin/echo -n ','
		encode "$new_url"
		/bin/echo -n ','
		encode "$old_browser"
		echo
	} >> "$tmp"
	mv "$tmp" "$BOOKMARKS_FILE"
}

do_modify ()
{
	height="$(wc -l < "$BOOKMARKS_FILE")"
	bm="$(print_names | run_dmenu "$height" 'Remove bookmark:')"

	entry="$(get_entry "$bm")"
	[ -z "$entry" ] && die 'ERROR: Bookmark does not exist'

	prop="$({
		echo '[browser]'
		echo '[name]'
		echo '[url]'
	} | run_dmenu 3 'Property:')"

	case "$prop" in
		'[browser]') modify_browser "$entry" ;;
		'[name]')    modify_name "$entry"    ;;
		'[url]')     modify_url "$entry"     ;;
		*)           die 'ERROR: No property selected' ;;
	esac
}

do_remove ()
{
	height="$(wc -l < "$BOOKMARKS_FILE")"
	bm="$(print_names | run_dmenu "$height" 'Remove bookmark:')"

	entry="$(get_entry "$bm")"
	[ -z "$entry" ] && die 'ERROR: Bookmark does not exist'

	tmp="$(mktemp)"
	grep --fixed-strings -v "$entry" "$BOOKMARKS_FILE" > "$tmp"
	mv "$tmp" "$BOOKMARKS_FILE"
}

do_open ()
{
	bm="$1"

	entry="$(get_entry "$bm")"
	[ -z "$entry" ] && die 'ERROR: Bookmark does not exist'

	url="$(decode_url "$entry")"
	browser="$(decode_browser "$entry")"

	exec $browser "$url"
}

main ()
{
	if [ ! -e "$BOOKMARKS_FILE" ]; then
		mkdir -p "$BOOKMARKS_DIR"
		touch "$BOOKMARKS_FILE"
	fi

	ret="$(intro_prompt)"

	case "$ret" in
		'')         die 'ERROR: No bookmark selected' ;;
		'[Insert]') do_insert      ;;
		'[Modify]') do_modify      ;;
		'[Remove]') do_remove      ;;
		*)          do_open "$ret" ;;
	esac
}

main "$@"
