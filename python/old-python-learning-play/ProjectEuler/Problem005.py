#!/usr/bin/env python3
"""Project Euler Problem 005

2520 is the smallest number that can be divided by each of the numbers from 
1 to 10 without any remainder.

What is the smallest number that is evenly divisible by all of the numbers 
from 1 to 20?
"""


for x in range(1000,1000000000000):
    for y in range(1,21):
        if x % y != 0: break
    else:
        print('winner',x,'!!!')
        break
