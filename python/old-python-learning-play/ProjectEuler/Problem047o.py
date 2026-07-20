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

target = 0
targetLen  = 4
x = 1
while not target:
    xFac = set(factorize(x))
    if len(xFac) == targetLen:
        yFac = set(factorize(x+1))
        if yFac != xFac and len(yFac)==targetLen:
            zFac = set(factorize(x+2))
            if zFac != yFac != xFac and len(zFac)==targetLen:
                qFac = set(factorize(x+3))
                if qFac != zFac != yFac != xFac and len(qFac)==targetLen:
                    target = x
    x += 1

print(target)
