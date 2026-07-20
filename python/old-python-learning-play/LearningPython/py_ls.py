#!/usr/bin/env python3
# ls in python, using ls
import os
P = os.popen('ls')
for line in P:
    print(line,end='')

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
