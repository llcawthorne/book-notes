#!/usr/bin/env python3
"""Project Euler Problem 020

n! means n × (n − 1) × ... × 3 × 2 × 1

Find the sum of the digits in the number 100!
"""
import math

n=0
x = math.factorial(100)
for digit in str(x):
    n+=int(digit)

print("Sum",n)
