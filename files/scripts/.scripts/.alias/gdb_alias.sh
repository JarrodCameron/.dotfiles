#!/bin/bash

# Author: Jarrod Cameron (z5210220)
# Date:   22/12/19  8:30

GDB_FLAGS="-quiet"

cmd="gdb ${GDB_FLAGS}"

pwn="$(locate -r '\/pwndbg\/gdbinit\.py$' | grep "^$HOME" | head -n1)"
if [ -r "$pwn" ]; then
	cmd="$cmd -command=$pwn"
fi

if [ -r "gdbinit" ]; then
	cmd="$cmd -command=gdbinit"
fi

exec $cmd $@
