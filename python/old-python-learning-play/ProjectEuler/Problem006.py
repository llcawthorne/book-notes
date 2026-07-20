#!/usr/bin/env python3
"""Project Euler Problem 006

The sum of the squares of the first ten natural numbers is,
1^(2) + 2^(2) + ... + 10^(2) = 385

The square of the sum of the first ten natural numbers is,
(1 + 2 + ... + 10)^(2) = 55^(2) = 3025

Hence the difference between the sum of the squares of the first ten 
natural numbers and the square of the sum is 3025 − 385 = 2640.

Find the difference between the sum of the squares of the first one 
hundred natural numbers and the square of the sum.
"""

sumOfSquares = 0
squareOfSums = 0

for x in range(1,101):
    sumOfSquares += x ** 2

for x in range(1,101):
    squareOfSums += x

squareOfSums = squareOfSums ** 2
difference = squareOfSums - sumOfSquares

print('The difference is',difference)
