#!/usr/bin/env python3

# A simple function based generator (notice yield instead of return)
def reverse(data):
    for index in range(len(data)-1, -1, -1):
        yield data[index]

for char in reverse('golf'):
    print(char, end=' ')
print()

# some generator expressions
print( sum(i*i for i in range(10)) )       # sum of squares

xvec = [10, 20, 30]
yvec = [7, 5, 3]
print( sum(x*y for x, y in zip(xvec, yvec)) )  # dot product

from math import pi, sin
sine_table = {x: sin(x*pi/180) for x in range(0, 91)}
# printable, but large - so commented out
# print(sine_table)

# this would work if for example, we read in a file
# unique_words = set(word for line in page for word in line.split())

data = 'golf'
print( list(data[i] for i in range(len(data)-1, -1, -1)) )
