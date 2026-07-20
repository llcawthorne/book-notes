#!/usr/bin/env python3
"""Project Euler Problem 047

The first two consecutive numbers to have two 
distinct prime factors are:

14 = 2 × 7
15 = 3 × 5

The first three consecutive numbers to have three 
distinct prime factors are:

644 = 2² × 7 × 23
645 = 3 × 5 × 43
646 = 2 × 17 × 19.

Find the first four consecutive integers to have four 
distinct primes factors. What is the first of these numbers?
"""
# Compared to Problem047o.py:
# This way is more general.  To change what it is looking for
# you only need to modify targetLen.
# Also, it is about 10% faster.
import math

def ld(n):
    for x in range(2,(math.ceil(math.sqrt(n))+1)):
        if n % x == 0: return x
    else:
        return n

def factorize(n):
    factors = []
    while n > 1:
        p = ld(n)
        n = int(n / p)
        factors.append(p)
    return factors[:]

targetLen  = 4

for x in range(1000000000):
    targetSet = set(factorize(x))
    if len(targetSet) != targetLen: continue
    for y in range(1,targetLen):
        targetFac = set(factorize(x+y))
        if len(targetFac) != targetLen: break
        elif targetSet == targetFac: break
    else:
        break

print(x)
