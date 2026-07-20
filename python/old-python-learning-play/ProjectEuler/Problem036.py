#!/usr/bin/env python3
"""Project Euler Problem 036

The decimal number, 585 = 1001001001_(2) (binary), is 
palindromic in both bases.

Find the sum of all numbers, less than one million, 
which are palindromic in base 10 and base 2.

(Please note that the palindromic number, in either base, 
may not include leading zeros.)
"""

allYourBase = []
base10Pals  = []
for x in range(1000000):
    if str(x) == str(x)[::-1]:
        base10Pals.append(x)

for pal in base10Pals:
    if (str(bin(pal)).lstrip('0b') 
        == str(bin(pal)).lstrip('0b')[::-1].lstrip('0') ):
        allYourBase.append(pal)

print(sum(allYourBase))
