#!/usr/bin/env python3
"""Project Euler Problem 007

By listing the first six prime numbers: 2, 3, 5, 7, 11, and 13, 
we can see that the 6(th) prime is 13.

What is the 10001(st) prime number?
"""
primes = []                                                                   
primes.append(2)
for x in range(3, int(10000**10000), 2):
    for p in primes:
        if x % p == 0: break
    else:
        primes.append(x)
    if len(primes) == 10001: break

print("It's",primes[-1])
