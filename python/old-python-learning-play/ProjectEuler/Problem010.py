#!/usr/bin/env python3
"""Project Euler Problem 010

The sum of the primes below 10 is 2 + 3 + 5 + 7 = 17.

Find the sum of all the primes below two million.
"""

primes = []
primes.append(2)
for x in range(3, 2000000, 2):
    for p in primes:
        if x % p == 0: break
    else:
        primes.append(x)

print('The sum is', sum(primes))
