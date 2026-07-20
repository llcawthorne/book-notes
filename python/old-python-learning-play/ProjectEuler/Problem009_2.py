#!/usr/bin/env python3
"""Project Euler Problem 009

A Pythagorean triplet is a set of three natural numbers, a < b < c, for which,
a^(2) + b^(2) = c^(2)

For example, 3^(2) + 4^(2) = 9 + 16 = 25 = 5^(2).

There exists exactly one Pythagorean triplet for which a + b + c = 1000.
Find the product abc.
"""

triplets = [(a, b, c) for a in range(1,1000) for b in range(1,1000)
                      for c in range(1,1000) if a + b + c == 1000]
thetriplet = [ tuple for tuple in triplets
               if tuple[0]**2 + tuple[1]**2 == tuple[2]**2]

print("The triplet is",thetriplet[0])
print("The product is",thetriplet[0][0]*thetriplet[0][1]*thetriplet[0][2])
