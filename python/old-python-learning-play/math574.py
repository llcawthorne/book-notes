#!/usr/bin/env python3
"""Extra Credit Assignment 1

Target: Factorize a number recursively.
Author: Lewis Cawthorne
Class : MATH574 - Discrete Mathematics
"""
import math       # for ceil function and sqrt

def factorize(n, fs):
    if n == 1:
        return fs
    for x in range(2, int((math.sqrt(n))+1)):
        if n % x == 0:
            fs.append(x)
            factorize( int(n/x) , fs )

fs = list()
factorize(100, fs)
print fs
