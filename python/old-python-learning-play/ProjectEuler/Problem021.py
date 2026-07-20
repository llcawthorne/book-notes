#!/usr/bin/env python3
"""Project Euler Problem 024

Let d(n) be defined as the sum of proper divisors of n 
(numbers less than n which divide evenly into n).
If d(a) = b and d(b) = a, where a ≠ b, then a and b are an 
amicable pair and each of a and b are called amicable numbers.

For example, the proper divisors of 220 are 1, 2, 4, 5, 10, 11, 20, 22, 44, 55 
and 110; therefore d(220) = 284. The proper divisors of 284 are 1, 2, 4, 71 
and 142; so d(284) = 220.

Evaluate the sum of all the amicable numbers under 10000.
"""
import math

def ld(n):
    for x in range(2,(math.ceil(math.sqrt(n))+1)):
        if n % x == 0: return x
    else:
        return n


def factors(n):
    myfactors = []
    while n > 1:
        p = ld(n)
        n = int(n / p)
        myfactors.append(p)
    return myfactors

def divisors(n):
    pfactors = list(set(factors(n)))
    mydivisors = pfactors[:]
    for x in mydivisors:
        for y in pfactors: 
            if n % (x*y) == 0: mydivisors.append(x*y)
    mydivisors.append(1)
    return sorted(set(mydivisors))

def d(n):
    return sum(x for x in divisors(n) if x < n)

def dlists():
    dlist = {}
    for x in range(10000):
        dlist[x] = d(x)
    return dlist

def amicable():
    pairs = []
    factorsums = dlists()
    for key in factorsums:
        for keyTwo in factorsums:
            if key == keyTwo: continue
            if key == factorsums[keyTwo]:
                if keyTwo == factorsums[key]:
                    pairs.append((key,keyTwo))
    return pairs

pairs = amicable()
nodupes = set()
for (a, b) in pairs:
    nodupes.add(a)
    nodupes.add(b)
print("The sum is",sum(nodupes))

