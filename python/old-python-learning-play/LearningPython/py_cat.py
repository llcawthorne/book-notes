#!/usr/bin/env python3
# cat in python
import sys
filename = sys.argv[1]
try:
    for line in open(filename):
        print(line,end='')
except:
    print(sys.argv[0],': ',
          sys.argv[1],': ',
          'No such file or directory')

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
