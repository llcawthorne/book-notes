#!/usr/bin/env python
# Euler's GCD
def gcd_eu(m, n):
    assert m > 0 or n > 0, "gcd_eu(0,0) not defined!"
    while n > 0:
        m, n = n, (m % n)
    return m

if __name__=='__main__':
    print "GCD 60, 24 is " + str(gcd_eu(60,24))
    print "GCD 71, 13 is " + str(gcd_eu(71,13))
    print "GCD 25, 20 is " + str(gcd_eu(25,20))
    print
