#!/usr/bin/env python3
"""Project Euler Problem 003

The prime factors of 13195 are 5, 7, 13 and 29.

What is the largest prime factor of the number 600851475143 ?
"""
import math

n = 600851475143

factors = []
while n % 2 == 0: 
    factors.append(2)
    n /= 2

for x in range(3,math.ceil(math.sqrt(n)),2):
    while n % x == 0:
        factors.append(x)
        n /= x
    if n in factors: break

print(factors[-1])
