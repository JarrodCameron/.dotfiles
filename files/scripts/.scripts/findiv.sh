#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   15/08/20 13:03

# Script to brute force "magic numbers" used by the compiler when multuplying
# or dividing ints

if [ "$#" != '1' ]
then
	echo 'Usage: findiv.sh <num>' >&2
	exit 1
fi

goal="$(echo "$1" | tr '[:upper:]' '[:lower:]')"

if [ -z "$(echo "$goal" | grep '^0x')" ]
then
	echo 'input needs to start with a "0x"' >&2
	exit 2
fi

if [ -n "$(echo "$goal" | grep '^0x0')" ]
then
	echo 'Input can not start with a "0x0"' >&2
	exit 3
fi

tmpin="$(mktemp)"'.c'
tmpout="$(mktemp)"

genfile () {
	num="$1"
	tmp="$2"

	cat << EOF > "$tmp"
int
mul(int n)
{
	return n * ==NUM==;
}

int
div(int n)
{
	return n / ==NUM==;
}

int
main(void)
{
	return 0;
}
EOF

	sed -i 's/==NUM==/'"$num"'/g' "$tmp"

}

clear

for i in `seq 2 2000000`
do
	genfile $i "$tmpin"
	gcc -m32 -fno-pie "$tmpin" -o "$tmpout"

	echo -ne 'Guess:' "$i" "\r"

	ret="$(/bin/gdb -batch -ex 'file '"$tmpout" -ex 'disassemble div' | grep "$goal")"

	if [ -n "$ret" ]
	then
		echo '=== WE ARE FINISHED ==='
		echo '=== Divisor:' "$i"
		break
	fi
done

rm -f "$tmpin" "$tmpout"

