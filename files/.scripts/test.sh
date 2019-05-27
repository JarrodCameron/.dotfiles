#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   27/05/19  6:29

seq 10 | while read -r a; do
    read -r b
    echo $a $b
done




