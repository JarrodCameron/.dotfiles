#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   07/10/19 18:34

IFS=''
source_file="$(for f in $(find . 2>/dev/null | grep -v '^\.$' | grep -v '\.class$')
do
    [ ! -d "$f" ] && echo $f
done | fzf --layout=reverse --margin=3 --header="pwd: $(pwd)" --inline-info --cycle)"

if [ -z "$source_file" ]
then
    exit 0
fi

case "$source_file" in
    *.pdf)  zathura "$source_file" &    ;;
    *)      vim "$source_file"          ;;
esac



