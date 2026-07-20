#!/usr/bin/env python3
"""Project Euler Problem 037

The number, 197, is called a circular prime because 
all rotations of the digits: 197, 971, and 719, 
are themselves prime.

There are thirteen such primes below 100: 
2, 3, 5, 7, 11, 13, 17, 31, 37, 71, 73, 79, and 97.

How many circular primes are there below one million?
"""

# Let's import a list of primes
primes = []
for line in open('1m_primes.txt'):
   line.rstrip()
   for num in line.split():
       prime = int(num)
       primes.append(prime)

lprimes = [x for x in primes if x < 1000000]
del primes

circPrime = []
for prime in lprimes:
    digiList = []
    for digit in str(prime):
        digiList.append(digit)
    for x in range(1,len(digiList)):
        if int(''.join(digiList[-x:]+digiList[:-x])) in lprimes:
            pass
        else:
            break
    else:
        circPrime.append(prime)

print(len(circPrime),'=>',circPrime)

