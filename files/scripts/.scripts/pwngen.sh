#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   06/16/20 10:11

# Exit on non-zero return status
set -e

if [ "$#" != '3' ]; then
	echo 'Usage: gen.sh </path/to/prog> <hostname> <port#>' >&2
	exit 1
elif [ -e './hak.py' ]; then
	echo 'ERROR: ./hak.py already exists, exiting now...' >&2
	exit 2
fi

exe="$1"
host="$2"
port="$3"

if [ ! -x "$exe" ]; then
	echo 'ERROR: '"$exe"' is not executable!!!' >&2
	exit 3
fi

print_hak_py () {

	cat << EOF
#!/usr/bin/env python3
# Author: ==NAME==
# Date:   ==DATE==

from pwn import *

context.arch = '==ARCH=='
context.bits = ==NBITS==
context.terminal = ['tmux', 'new-window']

'''
EOF

checksec --file "$exe" 2>&1

echo ''

file "$exe" | sed 's/, /\n/g' | sed 's/^/    /g'

cat << EOF
'''

def main(io):
    io.interactive()
    io.close()


if __name__ == '__main__':
    if args['REMOTE']:
        io = remote('==HOST==', ==PORT==)
    elif args['GDB']:
        gs = '''
        b main
        '''
        io = gdb.debug('==EXEC==', gs)
    else:
        io = process('==EXEC==')
    main(io)

EOF

}

print_hak_py > hak.py

sed -i 's/==NAME==/Jarrod Cameron (z5210220)/g' hak.py
sed -i 's#==DATE==#'"$(date '+%x %k:%M')"'#g' hak.py
sed -i 's/==HOST==/'"$host"'/g' hak.py
sed -i 's/==PORT==/'"$port"'/g' hak.py
sed -i 's#==EXEC==#'"$exe"'#g' hak.py

class="$(readelf -h "$exe" | awk '/Class:/ {print $2}')"
if [ "$class" = 'ELF32' ]; then
	sed -i 's/==NBITS==/32/g' hak.py
	sed -i 's/==ARCH==/i386/g' hak.py
elif [ "$class" = 'ELF64' ]; then
	sed -i 's/==NBITS==/64/g' hak.py
	sed -i 's/==ARCH==/amd64/g' hak.py
else
	echo 'ERROR: Unknow bits, broken header?' >&2
	exit 4
fi


