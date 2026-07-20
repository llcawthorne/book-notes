#!/usr/bin/env python3
# A simple Python quote generator
import random

lines = 0
with open('./quotes.txt', 'r') as f:
    quotelist = f.readlines()

print(quotelist)

# loopcount is just to ensure no infinite loops
loopcount = 0
while loopcount < 5:
    loopcount = loopcount + 1
    linenum = random.randrange(len(quotelist))
    # ignore blank lines
    if quotelist[linenum] == '\n':
        continue
    print()
    print(quotelist[linenum])
    print()
    break

