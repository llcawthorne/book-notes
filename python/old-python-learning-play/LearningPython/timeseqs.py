#!/usr/bin/env python3
# File timeseqs.py
# Compares ways of implementing abs across a list

import sys, mytimer
import math
reps = 10000
repslist = range(reps)
pointFiveList = [ 0.5 ] * reps

def forMathFunc():
    res = []
    for x in repslist:
        res.append(math.sqrt(x))
    return res

def forTwoStars():
    res = []
    for x in repslist:
        res.append(x**0.5)
    return res

def forPowFunc():
    res = []
    for x in repslist:
        res.append(pow(x,0.5))
    return res

def mathFunc():
    return list(map(math.sqrt, repslist))

def twoStars():
    return [x ** .5 for x in repslist]

def powFunc():
    return list(map(pow, repslist, pointFiveList))

print(sys.version)
for test in (forMathFunc, forTwoStars, forPowFunc, mathFunc, twoStars, powFunc):
    elapsed, result = mytimer.timer(test)
    print('-' * 33)
    print('%-9s: %.5f => [%s...%s]' %
          (test.__name__, elapsed, result[0], result[-1]))
