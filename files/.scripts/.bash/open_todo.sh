#!/usr/bin/env bash

# Author: Jarrod Cameron (z5210220)
# Date:   24/10/19 12:49

line="$(grep -nr "TODO" | fzf --layout=reverse --margin=3 --header="pwd: $(pwd)" --inline-info --cycle)"

if [ -z "$line" ]; then
    exit 1
fi

# If there is a ':' in the file name or path we are fked
file_name="$(echo $line | awk -F':' '{print $1}')"
line_num="$(echo $line | awk -F':' '{print $2}')"

vim "$file_name" +"$line_num"


