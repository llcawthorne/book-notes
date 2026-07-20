#!/usr/bin/env python3
# File timeseqs.py
# Compares ways of implementing addition by function across a list

import sys, mytimer
reps = 10000
repslist = range(reps)

def addTen(x):
    return x + 10

def forLoop():
    res = []
    for x in repslist:
        res.append(addTen(x))
    return res

def listComp():
    return [addTen(x) for x in repslist]

def mapCall():
    return list(map(addTen, repslist))

def genExpr():
    return list(addTen(x) for x in repslist)

def genFunc():
    def gen():
        for x in repslist:
            yield addTen(x)
    return list(gen())

print(sys.version)
for test in (forLoop, listComp, mapCall, genExpr, genFunc):
    elapsed, result = mytimer.timer(test)
    print('-' * 33)
    print('%-9s: %.5f => [%s...%s]' %
          (test.__name__, elapsed, result[0], result[-1]))
