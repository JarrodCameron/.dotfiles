#!/usr/bin/env python3
# Author: Jarrod Cameron (z5210220)
# Date:   07/29/22 21:39

import os
import gdb

dir_name = os.path.dirname(__file__)
file_list = os.listdir(dir_name)

for f in file_list:
    # Don't match with this file
    if f == os.path.basename(__file__):
        continue

    if f == '__pycache__':
        continue
    if f == 'pwndbg':
        continue

    if f.endswith('.swp'):
        continue

    gdb.execute(f'source {dir_name}/{f}')
