#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   23/11/23 10:03

# Exit on non-zero return status
set -e

# TODO Should be able to search google from here

LOCAL_STATE_FILE="$HOME"'/.config/google-chrome/Local State'
MODIFIER_NEW_WINDOW='(( New Window ))'
MODIFIER_INCOGNITO='(( Private ))'

die () {
	msg="$1"
	retval="$2"

	echo "$msg" >&2
	exit "$retval"
}

# Google chrome required profile IDs, but dmenu returns a profile name. So we
# convert the name to an ID
profile_name_to_id () {
	# TODO This shouldn't be a loop.
	target_profile_name="$1"
	jq --raw-output '.profile.info_cache | keys[]' "$LOCAL_STATE_FILE" | while read profile_id
	do
		profile_name="$(jq --raw-output --arg profile_id "$profile_id" '.profile.info_cache[$profile_id].name' "$LOCAL_STATE_FILE")"
		if [ "$profile_name" = "$target_profile_name" ]; then
			/bin/echo "$profile_id"
			break
		fi
	done
}

run_dmenu () {
	height="$1"
	input_file="$2"
	dmenu -i \
		-l "$height" \
		-p 'Open Bookmark:' \
		-fn 'monospace:size=10' \
		-nb "#282828" \
		-nf "#ebdbb2" \
		-sf "#1d2021" \
		-sb "#689d68" < "$input_file"
}

tmpfile="$(mktemp)"
jq --raw-output '.profile.info_cache | keys[]' "$LOCAL_STATE_FILE" | while read profile_id
do
	bookmarks_file="$HOME"'/.config/google-chrome/'"$profile_id"'/Bookmarks'

	profile_name="$(jq \
		--raw-output \
		--arg profile_id "$profile_id" \
		'.profile.info_cache[$profile_id].name' \
		"$LOCAL_STATE_FILE")"

	jq \
		--raw-output \
		--arg profile_name "$profile_name"  \
		'.roots | .. | select(.type? == "url") | @text "[\($profile_name)] \(.name)"' \
		"$bookmarks_file"
done | sort > "$tmpfile"
echo "$MODIFIER_NEW_WINDOW" >> "$tmpfile"
echo "$MODIFIER_INCOGNITO" >> "$tmpfile"

height="$(wc -l "$tmpfile")"
line=''
args=''
while [ -z "$line" ]
do
	ret="$(run_dmenu "$height" "$tmpfile")"
	if [ "$ret" = "$MODIFIER_NEW_WINDOW" ]; then
		args="$args --new-window"
	elif [ "$ret" = "$MODIFIER_INCOGNITO" ]; then
		args="$args --incognito"
	else
		line="$ret"
	fi
done
rm -f "$tmpfile"


target_profile_name="$(echo "$line" | sed -nr 's/^\[(.*)\] .*$/\1/p')"
[ -z "$target_profile_name" ] && die 'ERROR: Invalid input from dmenu. Could not get profile name' 2

target_profile_id="$(profile_name_to_id "$target_profile_name")"
[ -z "$target_profile_id" ] && die 'ERROR: Could not convert profile name to profile id' 4

target_bookmark_name="$(echo "$line" | sed -nr 's/^\[.*\] (.*)$/\1/p')"
[ -z "$target_bookmark_name" ] && die 'ERROR: Could not extract bookmark name' 4

bookmarks_file="$HOME"'/.config/google-chrome/'"$target_profile_id"'/Bookmarks'
target_bookmark_url="$(jq \
	--raw-output \
	--arg bookmark_name "$target_bookmark_name" \
	'.roots | .. | select(.type? == "url" and .name? == $bookmark_name).url' \
	"$bookmarks_file"
)"
[ -z "$target_bookmark_url" ] && die 'ERROR: Could not extract bookmark url' 5

google-chrome-stable $args --profile-directory="$target_profile_id" "$target_bookmark_url"
