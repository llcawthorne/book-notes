#!/usr/bin/env python
"""ccwd.py copies the current working directory to the clipboard unless given
a command line argument in which case it changes to that directory then copies
it to the clipboard"""

import pyperclip, os, sys

if len(sys.argv) > 1:
    os.chdir(sys.argv[1])

pyperclip.copy(os.getcwd())
