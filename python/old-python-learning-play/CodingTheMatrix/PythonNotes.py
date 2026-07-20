#!/usr/bin/env python3
## Python Notes ##

# Sets in Python #
S = {1,2,3}                            # set notation
# | (pipe) for union, & for intersection
# ‘in’ and ‘not in’ for membership testing
# mutate set, update to add multiple elements
S.add(4)
S.remove(4)
S.update({4,5,6})
# update S to the intersection of S and the argument
S.intersection_update({5,6,7})
# make U into a distinct copy of S that can be modified separately
U = S.copy()
S = {2*x for x in {1,2,3}}            # set comprehensions
# a comprehension based on S union {5,7} if x > 2
T = {x*x for x in S | {5,7} if x > 2}
