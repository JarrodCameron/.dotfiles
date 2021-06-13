#!/usr/bin/env python3
# Author: Jarrod Cameron (z5210220)
# Date:   05/05/21  9:55

import os
import subprocess
import time

DELAY = 5

def main():
    string = b''
    print('Enter file:')
    while True:
        b = os.read(0, 1)
        if len(b) == 0:
            break
        string += b

    for n in range(DELAY, 0, -1):
        print(f'Sending keys in: {n}')
        time.sleep(1)

    for s in string:
        subprocess.run(['xdotool', 'type', chr(s)])

if __name__ == '__main__':
    main()

