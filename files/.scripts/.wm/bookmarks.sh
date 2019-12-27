#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   25/08/19 11:29

# Reads the boomarks from the file in the secret directory ($SECRET_DIR).
# If the file does not exist it is created.
# The format of the file is:
# +----------+
# | name1    |
# | url1     |
# | name2    |
# | url2     |
# | ...      |
# | nameN    |
# | urlN     |
# +----------+

BLACK="#282828"
WHITE="#ebdbb2"
GRAY="#1d2021"
AQUA="#689d68"
COLORS="-nb $BLACK -nf $WHITE -sf $GRAY -sb $AQUA"

SECRET_DIR="$HOME""/.dotfiles/secret"
SECRET_FILE="$SECRET_DIR""/bookmarks.txt"

mkdir -p "$SECRET_DIR"
touch "$SECRET_FILE"

max_len="$(awk '\
    BEGIN {
        max_len = 0;
    }
    NR%2==0 {
        // Skip odd lines
        next
    }
    {
        if (length($0) > max_len) {
            max_len = length($0)
        }
    }
    END {
        print max_len + 1
    }
' "$SECRET_FILE")"

n_bmarks="$(echo `awk 'END{print NR}' "$SECRET_FILE"` ' / 2' | bc)"
n_lines="$(echo "$n_bmarks + 2" | bc)"

url="$( (awk '\
    {
        name=$0;
        getline;
        url=$1;
        printf "%-'$max_len's--> %s\n", name, url;
    }
\' "$SECRET_FILE" | sort -d -f ; echo "[Update]\n[Remove]" ) | dmenu -i -l "$n_lines" -p "Open bookmark:" $COLORS | sed 's/^.* --> //')"

if [ -z "$url" ]; then
    # pass
    exit 0
elif [ "$url" = "[Update]" ]; then
    bm_name="$(dmenu -p "Bookmark name:" $COLORS < /dev/null)"
    bm_url="$(dmenu -p "Bookmark url:" $COLORS < /dev/null)"
    if [ -n "$bm_name" ] && [ -n "$bm_url" ]; then
        echo "$bm_name" >> "$SECRET_FILE"
        echo "$bm_url" >> "$SECRET_FILE"
    fi
elif [ "$url" = "[Remove]" ]; then
    del="$(awk '\
        {
            name=$0;
            getline;
            url=$1;
            printf "%-'$max_len's--> %s\n", name, url;
        }
    \' "$SECRET_FILE" | sort -d -f | dmenu -i -l "$n_bmarks" -p "Remove bookmark:" $COLORS | sed 's/^.* --> //')"
    sponge="$(mktemp)"

    awk '\
    {
        name=$0
        getline
        url=$1
        if (url != "'$del'") {
            printf "%s\n", name
            printf "%s\n", url
        }
    }
    \' "$SECRET_FILE" > "$sponge"

    mv "$sponge" "$SECRET_FILE"

    rm -f "$sponge"
else
    firefox -new-window "$url"
fi
