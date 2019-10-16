#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   07/10/19 18:34

source_file="$(for f in $(find . | grep -v '^\.$')
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



