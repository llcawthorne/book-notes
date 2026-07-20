#!/usr/bin/env python3
# I have this same code in the bottom of for.py, but it is a useful
# example of both a mildly complex for loop and prime finding technique
for n in range(2, 100):
    for x in range(2, n):
        if n % x == 0:
            # print(n, 'equals', x, '*', n//x)
            break
    else:
        # loop fell through without finding a factor
        print(n, 'is a prime number')
