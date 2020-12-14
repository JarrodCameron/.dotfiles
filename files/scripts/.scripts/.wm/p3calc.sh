#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   05/11/20 20:54

# Exit on non-zero return status
set -e

exec termite --title='p3calc' --exec='python3 -q'

