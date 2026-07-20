#!/usr/bin/env python3
"""Project Euler Problem 003

The prime factors of 13195 are 5, 7, 13 and 29.

What is the largest prime factor of the number 600851475143 ?
"""
import math

n = 600851475143

# Let's import a list of primes
primes = []
# for line in open('1m_primes.txt'):
#    line.rstrip()
#    for num in line.split():
#        prime = int(num)
#        primes.append(prime)
primes.append(2)
for x in range(3, (math.ceil(math.sqrt(n))+1), 2):
    if (x-1) % 6 != 0 and (x+1) % 6 != 0: continue
    for p in primes:
        if x % p == 0: break
    else:
        primes.append(x)

for prime in sorted(primes, reverse=True):
    if n % prime == 0:
        print(prime, 'is a prime factor.')
        break
else:
    print(n, 'is prime.')
