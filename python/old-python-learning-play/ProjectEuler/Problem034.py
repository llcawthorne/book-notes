#!/usr/bin/env python3
"""Project Euler Problem 034

145 is a curious number, as 1! + 4! + 5! = 1 + 24 + 120 = 145.

Find the sum of all numbers which are equal to the sum of the factorial of their digits.

Note: as 1! = 1 and 2! = 2 are not sums they are not included.
"""
import math

# 9! * 8 is only a 7 digit number
# so we don't have to go larger than this
fnine = math.factorial(9)*7
x = 145
curious = []
for x in range(10,fnine):
    n = 0
    for digit in str(x):
        n += math.factorial(int(digit))
    if x == n: 
        curious.append(x)

print('The curious numbers sum to',sum(curious))
