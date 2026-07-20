#!/usr/bin/env python3
"""Project Euler Problem 009

A Pythagorean triplet is a set of three natural numbers, a < b < c, for which,
a^(2) + b^(2) = c^(2)

For example, 3^(2) + 4^(2) = 9 + 16 = 25 = 5^(2).

There exists exactly one Pythagorean triplet for which a + b + c = 1000.
Find the product abc.
"""

def findTriplet():
    for a in range(1,1000):
        for b in range(1,1000):
            for c in range(1,1000):
                if a + b + c == 1000:
                    if a**2 + b**2 == c**2:
                        return a, b, c

a, b, c = findTriplet()
print("The triplet is",a,b,c)
print("The product is",a*b*c)
