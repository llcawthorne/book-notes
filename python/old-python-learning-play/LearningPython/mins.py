#!/usr/bin/env python3
def min1(*args):
    res = args[0]
    for arg in args[1:]:
        if arg < res:
            res = arg
    return res

def min2(first, *rest):
    for val in rest:
        if val < first:
            first = val
    return first

def min3(*args):
    L = sorted(list(args))
    return L[0]

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
