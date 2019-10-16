#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   02/10/19 21:24

msg=''

msg+='AAAA'
msg+=$(printf '\xff\x01')
msg+='BBBB'

printf '%s' $msg




