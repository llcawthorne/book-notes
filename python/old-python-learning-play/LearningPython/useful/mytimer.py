#!/usr/bin/env python3
# File mytimer.py

import time
reps = 1000
repslist = range(reps)

def timer(func, *pargs, **kargs):
    start = time.time()
    for i in repslist:
        ret = func(*pargs, **kargs)
    elapsed = time.time() - start
    return (round(elapsed,5), ret)

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
