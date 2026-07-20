#!/usr/bin/env python
import sys

# Sieve of Eratosthenes
def sieve_erat(n):
    """Returns an array of ints with all primes less than or equal to n"""
    assert n>1, "sieve_erat: You can't really sieve on n<=1..."
    result  = []
    temp    = [x for x in range(n+1)]
    temp[1] = 0         # Eliminate 1
    # need to check from 2 to the ceiling of sqrt(n)
    # it might be floor..  I never can remember, so playing safe
    for i in range(2,int(n**0.5)+1):
        # Has this position not been eliminated?
        if temp[i] != 0:
            # Start at i^2, smaller multiples of 'i' will be gone already
            j=i*i
            # Eliminate every i'th entry from i^2 up to n (inclusive)
            # "Crossing out" is hard, zero'ing is simple
            while j <= n:
                temp[j] = 0
                j=j+i
    # Nice! One more pass to collect what hasn't be zero'd (primes)
    for i in range(2,n+1):
        if temp[i] != 0:
            result.append(temp[i])
    return result

if __name__=='__main__':
    # print "Primes below ", upper, " are", str(sieve_erat(upper))
    if len(sys.argv)==1:
        upper = 104744
    else:
        upper = int(sys.argv[1])
    primes = sieve_erat(upper)
    print "There are", len(primes), "primes under", upper
    print "First ten:", primes[0:10]
    print "Last prime:", primes[-1]
