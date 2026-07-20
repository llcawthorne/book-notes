#!/usr/bin/env python3
# This program demonstrates two ways to write a table of squares and cubes
# This way demonstrates the rjust() method of string objects
for x in range(1, 11):
    print( repr(x).rjust(2), repr(x*x).rjust(3), end=' ')
    print( repr(x*x*x).rjust(4) )
print()
# This way demonstrates the .format method of strings
for x in range(1, 11):
    print('{0:2d} {1:3d} {2:4d}'.format(x, x*x, x*x*x))

# Some other interesting string format methods include:
# ljust() to left justify, center() to center the string
# and zfill() to pad a numeric string with zeroes
