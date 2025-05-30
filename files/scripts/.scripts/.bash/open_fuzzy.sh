#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   07/10/19 18:34

show=cat
[ -n "$(which bat)" ] && show="$(which bat) --style plain --color always"
[ -n "$(which batcat)" ] && show="$(which batcat) --style plain --color always"

source_file="$(find ! -name '*.class' -type f 2>/dev/null | fzf \
	--preview="$show {}" \
	--layout=reverse \
	--margin=3 \
	--header="pwd: $(pwd)" \
	--inline-info \
	--cycle
)"

if [ -z "$source_file" ]
then
    exit 0
fi

case "$source_file" in
    *.pdf)  zathura "$source_file" &>/dev/null &    ;;
    *.png)  feh "$source_file" &        ;;
    *.jpg)  feh "$source_file" &        ;;
    *.webm) mpv "$source_file" &        ;;
    *.mkv)  mpv "$source_file" &        ;;
    *.sc)   sc "$source_file" &         ;;
    *)      exec vim "$source_file"     ;;
esac
