#!/usr/bin/env bash

# Author: Jarrod Cameron (z5210220)
# Date:   22/12/19  8:30

GDB_FLAGS="-quiet"

if [ -r "gdbinit" ]; then
    gdb "${GDB_FLAGS}" -command="gdbinit" $@
else
    gdb "${GDB_FLAGS}" $@
fi




