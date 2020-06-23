#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   19/01/20 13:40

[ -z "$BROWSER" ] && BROWSER='firefox'

BOOKMARKS_DIR="$HOME"'/.cache/bookmarks/'
BOOKMARKS_FILE="$BOOKMARKS_DIR"'bookmarks.json'

# Simple dmenu wrapper
run_dmenu () {
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

# Given the name of a bookmark open it up
do_open () {
    bm_name="$1"

    bm_status="$(jq --raw-output '.'"\"${bm_name}\"" "${BOOKMARKS_FILE}")"

    if [ "$bm_status" = 'null' ]; then
        printf 'Unknown bookmark: %s\n' "$bm_name" >&2
        exit 0
    fi

    bm_url="$(jq --raw-output '."'"$bm_name"'".url' "$BOOKMARKS_FILE")"
    bm_browser="$(jq --raw-output '."'"$bm_name"'".browser' "$BOOKMARKS_FILE")"

    $bm_browser "$bm_url"
}

# Get the bookmark name from the user
get_bm_name () {
    bm_name="$(run_dmenu 0 'Bookmark name:' < /dev/null)"
    if [ -z "$bm_name" ]; then
        printf ''
        exit 0
    fi

    status="$(jq '."'"$bm_name"'"' "$BOOKMARKS_FILE")"

    if [ "$status" != 'null' ]; then
        printf ''
    else
        printf '%s' "${bm_name}"
    fi
}

# Get the bookmark url from the user
get_bm_url () {
    run_dmenu 0 "Bookmark url:" < /dev/null
}

# Get the bookmark browser from the user
get_bm_browser () {
    printf 'firefox
firefox --new-window
firefox --private-window
brave
' | run_dmenu 4 'Browser:'
}

# Prompt user for new bookmark and save it
do_insert () {

    bm_name="$(get_bm_name)"
    [ -z "$bm_name" ] && exit 1

    bm_url="$(get_bm_url)"
    [ -z "$bm_url" ] && exit 1

    bm_browser="$(get_bm_browser)"
    [ -z "$bm_browser" ] && exit 1

    new_bookmarks_temp="$(mktemp)"
{
    cat "$BOOKMARKS_FILE"
        printf '{
    "%s" : {
        "url" : "%s",
        "browser" : "%s"
    }
}\n' "$bm_name" "$bm_url" "$bm_browser"
} | jq --raw-output --slurp add > "$new_bookmarks_temp"

    mv "$new_bookmarks_temp" "$BOOKMARKS_FILE"

}

# Remove an entry from the $BOOKMARKS_FILE
do_remove () {
    bm_height="$(jq '. | length' "${BOOKMARKS_FILE}")"
    bm_name="$(jq --raw-output '. | keys[]' "${BOOKMARKS_FILE}" | sort |
        run_dmenu "$bm_height" 'Remove bookmark:')"

    temp_file="$(mktemp)"

    jq 'del(."'"$bm_name"'")' "$BOOKMARKS_FILE" > "$temp_file"
    mv "$temp_file" "$BOOKMARKS_FILE"
}

# Modify an entry in the $BOOKMARKS_FILE
do_modify () {
    bm_height="$(jq '. | length' "${BOOKMARKS_FILE}")"
    bm_name="$(jq --raw-output '. | keys[]' "${BOOKMARKS_FILE}" | sort |
        run_dmenu "$bm_height" 'Modify bookmark:')"

    if [ -z "$bm_name" ]; then
        exit 0
    elif [ "$(jq '."'$bm_name'"' "${BOOKMARKS_FILE}")" = 'null' ]; then
        exit 0
    fi

    prop="$(printf '%s\n%s\n%s\n' '[browser]' '[name]' '[url]' | run_dmenu 3 'Property:')"

    curr_url="$(jq --raw-output '."'"$bm_name"'".url' "${BOOKMARKS_FILE}")"
    curr_browser="$(jq --raw-output '."'"$bm_name"'".browser' "${BOOKMARKS_FILE}")"
    curr_name="$bm_name"

    if [ -z "$prop" ]; then
        exit 0
    elif [ "$prop" = '[url]' ]; then
        curr_url="$(get_bm_url)"
        [ -z "$curr_url" ] && exit 0
    elif [ "$prop" = '[name]' ]; then
        curr_name="$(get_bm_name)"
        [ -z "$curr_name" ] && exit 0
    elif [ "$prop" = '[browser]' ]; then
        curr_browser="$(get_bm_browser)"
        [ -z "$curr_browser" ] && exit 0
    else
        exit 0
    fi

    new_bookmarks_temp="$(mktemp)"
{
    jq --raw-output 'del(."'$bm_name'")' "$BOOKMARKS_FILE"
        printf '{
    "%s" : {
        "url" : "%s",
        "browser" : "%s"
    }
}\n' "$curr_name" "$curr_url" "$curr_browser"
} | jq --raw-output --slurp add > "$new_bookmarks_temp"

    mv "$new_bookmarks_temp" "$BOOKMARKS_FILE"

}

if [ ! -e "$BOOKMARKS_FILE" ]; then
    mkdir -p "$BOOKMARKS_DIR"
    printf '{}' > "$BOOKMARKS_FILE"
fi

bm_height="$(jq '. | length' "${BOOKMARKS_FILE}")"
bm_height="$((bm_height+3))"

bm_name="$({
    jq --raw-output '. | keys[]' "${BOOKMARKS_FILE}" | sort
    cat << EOF
[Insert]
[Modify]
[Remove]
EOF
} | run_dmenu "$bm_height" 'Open bookmark:')"

if [ -z "$bm_name" ]; then
    exit 1
fi

case "$bm_name" in
    '[Insert]') do_insert          ;;
    '[Modify]') do_modify          ;;
    '[Remove]') do_remove          ;;
    *)          do_open "$bm_name" ;;
esac


