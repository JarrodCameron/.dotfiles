#!/bin/bash

# Author: Jarrod Cameron (z5210220)
# Date:   22/12/19  8:30

GDB_FLAGS="-quiet"

if [ -r "gdbinit" ]; then
	exec gdb "${GDB_FLAGS}" -command="gdbinit" $@
else
	exec gdb "${GDB_FLAGS}" $@
fi
