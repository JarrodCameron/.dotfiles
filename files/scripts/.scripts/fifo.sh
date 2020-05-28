#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   28/04/20 14:54

# Scans list of open ports and returns port# that is free for our program.
# Saves messing with a port number each time
get_free_portnum () {
	t=1024
	while [ -n "$(netstat -an | grep "$t")" ]
	do
		t=$((t+1))
	done
	printf "$t"
}

if [ "$#" != '1' ]; then
	echo 'Usage: fifo /path/to/executable' >&2
	exit 1
fi

prog="$1"
if [ ! -x "$prog" ]; then
	printf '"%s" is not executable!\n' "$prog"
	exit 2
fi

fifo_dir="$(mktemp -d)"

fifo_path="$fifo_dir"'/fifo'

port_num="$(get_free_portnum)"
printf 'Port: %s\n' "$port_num"

mknod "$fifo_path" p

echo $fifo_path
echo $fifo_path
echo $fifo_path

echo $prog
echo $prog
echo $prog

nc -l "$port_num"

#nc -l "$port_num" <"$fifo_path" | "$prog" >"$fifo_path"


# Run program reading from pipe, output back to pipe
#"$prog" <"$fifo_path" 2>&1 | nc -l "$port_num" &>"$fifo_path"

# Cleanup
rm -rf "$fifo_dir"
