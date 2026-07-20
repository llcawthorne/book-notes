#!/usr/bin/env python3
"""Project Euler Problem 003

The prime factors of 13195 are 5, 7, 13 and 29.

What is the largest prime factor of the number 600851475143 ?
"""
# This is order's of magnitude faster than Problem003o.py
# and even faster that Problem003_list.py (that uses a list of primes).
import math

def ld(n):
    for x in range(2,(math.ceil(math.sqrt(n))+1)):
        if n % x == 0: return x
    else:
        return n

n = 600851475143

factors = []
while n > 1:
    p = ld(n)
    n = int(n / p)
    factors.append(p)

print("The greatest factor is",factors[-1])
