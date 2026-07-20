#!/usr/bin/env python3
# File mytimer_new.py
"""
A more sophisticated timer than what is in mytimer.py

timer(spam, 1, 2, a=3, b=4, _reps=1000) calls and times
spam(1, 2, a=3, b=4) _reps times, and returns total time for all runs
with final result;

best(spam, 1, 2, a=3, b=4, _reps=50) runs best-of-N timer to filter
out any system load variation, and returns best time among _reps tests
"""

import time, sys
if sys.platform[:3] == "win":
    timefunc = time.clock       # Use time.clock on Windows
else:
    timefunc = time.time        # Better granularity in Unix

def trace(*args): pass          # Or: print args

def timer(func, *pargs, **kargs):
    _reps = kargs.pop('_reps', 1000)    # Passed in or default reps
    trace(func, pargs, kargs, _reps)
    repslist = list(range(_reps))
    start = timefunc()
    for i in repslist:
        ret = func(*pargs, **kargs)
    elapsed = timefunc() - start
    return (elapsed, ret)

def best(func, *pargs, **kargs):
    _reps = kargs.pop('_reps', 50)
    best = 2 ** 32
    for i in range(_reps):
        (time, ret) = timer(func, *pargs, _reps=1, **kargs)
        if time < best: best = time
    return (best, ret)

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
