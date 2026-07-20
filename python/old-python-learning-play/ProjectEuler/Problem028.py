#!/usr/bin/env python3
"""Project Euler Problem 028

Starting with the number 1 and moving to the right in a 
clockwise direction a 5 by 5 spiral is formed as follows:

    21 22 23 24 25
    20  7  8  9 10
    19  6  1  2 11
    18  5  4  3 12
    17 16 15 14 13

    It can be verified that the sum of the numbers on the 
    diagonals is 101.

    What is the sum of the numbers on the diagonals in a 
    1001 by 1001 spiral formed in the same way?
"""

row = 500
col = 500

n   = 1
modifier = 1

spiral = {}
spiral[(row,col)] = n
while modifier < 1001:
    for x in range(modifier):
        col += 1
        n   += 1
        spiral[(row,col)] = n
    for x in range(modifier):
        row += 1
        n   += 1
        spiral[(row),col] = n
    modifier += 1
    for x in range(modifier):
        col -= 1
        n   += 1
        spiral[(row),col] = n
    for x in range(modifier):
        row -= 1
        n   += 1
        spiral[(row),col] = n
    modifier += 1
if (row,col) == (0,0):
    for x in range(1001):
        spiral[0,x] = n
        n+=1

diagSum = 0
for x in range(1001):
    diagSum += spiral[(x,x)]
    if x != (1000-x):
        diagSum += spiral[(x,(1000-x))]

print("DiagSum:",diagSum)
