#!/usr/bin/env bash

# Author: Jarrod Cameron (z5210220)
# Date:   22/10/19  7:19

echo 'Enter search term:'
echo -n '-> '

#read -r word
word="$(python3 -c 'print(input(),)')"
echo "-> $word <-"

if [ -z "$word" ]; then
    exit 0
fi

line="$(grep -nr "$word" | fzf --layout=reverse --margin=3 --header="pwd: $(pwd)" --inline-info --cycle)"

# If there is a ':' in the file name or path we are fked
file_name="$(echo $line | awk -F':' '{print $1}')"
line_num="$(echo $line | awk -F':' '{print $2}')"

echo "file_name -> $file_name"
echo "line_num  -> $line_num"

vim "$file_name" +"$line_num"






