#!/usr/bin/env python3
"""Project Euler Problem 016

2^(15) = 32768 and the sum of its digits is 3 + 2 + 7 + 6 + 8 = 26.

What is the sum of the digits of the number 2^(1000)?
"""

number = 2 ** 1000
answer = 0
for digit in str(number):
    answer += int(digit)

print("Answer is",answer)
