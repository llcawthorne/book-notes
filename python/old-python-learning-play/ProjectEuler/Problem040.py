#!/usr/bin/env python3
"""Project Euler Problem 040

An irrational decimal fraction is created by concatenating 
the positive integers:

    0.123456789101112131415161718192021...

It can be seen that the 12^(th) digit of the fractional 
part is 1.

If d_(n) represents the n^(th) digit of the fractional 
part, find the value of the following expression.

d_(1) × d_(10) × d_(100) × d_(1000) × d_(10000) × d_(100000) × d_(1000000)
"""

rational = '.'
digit = 1
while len(rational) <= 1000000:
    rational += str(digit)
    digit += 1 

result = (int(rational[1])        * 
          int(rational[10])       *
          int(rational[100])      *
          int(rational[1000])     *
          int(rational[10000])    *
          int(rational[100000])   *
          int(rational[1000000])  )

print("And the result is",result)
