#!/usr/bin/env python3
"""Project Euler Problem 053

There are exactly ten ways of selecting three from five, 12345:

123, 124, 125, 134, 135, 145, 234, 235, 245, and 345

In combinatorics, we use the notation, ^(5)C_(3) = 10.

In general,
^(n)C_(r) =     
n!
r!(n−r)!
    ,where r ≤ n, n! = n×(n−1)×...×3×2×1, and 0! = 1.

It is not until n = 23, that a value exceeds one-million: 
^(23)C_(10) = 1144066.

How many, not necessarily distinct, values of  
^(n)C_(r), for 1 ≤ n ≤ 100, are greater than one-million?
"""
import math as M

def nCr(n, r):
    return int(M.factorial(n) / (M.factorial(r) * M.factorial(n-r)))

# brute force
overMil = []

for x in range(1,101):
    for y in range(x):
        val = nCr(x,y)
        if val > 1000000:
            overMil.append(val)

print(len(overMil), 'values')
