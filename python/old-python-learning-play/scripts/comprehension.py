#!/usr/bin/env python3
# List Comprehensions
# A comprehension is a concise way to create lists from sequences.
# It consists of brackets containing an expressino followed by a for clause,
# then zero or more for or if clauses.  The result will be a list resulting
# from evaluating the expression in the context of the for and if clauses.
vec = [2, 4, 6]
print(vec)
print( [3*x for x in vec] )
print( [[x, x**2] for x in vec] )
print( [(x, x**2) for x in vec] )
# if clauses can be used
print( [3*x for x in vec if x > 3] )
print( [3*x for x in vec if x < 2] )
# Here is a method call for each item in a sequence:
freshfruit = ['   banana', '  loganberry ', 'passion fruit  ']
print(freshfruit)
print( [weapon.strip() for weapon in freshfruit] )
# Nested loops work for something fancier
vec1 = [2, 4, 6]
vec2 = [4, 3, -9]
# 2*4, 2*3, 2*-9, 4*4, 4*3, 4*-9, 6*4, 6*3, 6*-9
print( [x*y for x in vec1 for y in vec2] )
print( [x+y for x in vec1 for y in vec2] )
# 2*4, 4*3, 6*-9
print( [vec1[i]*vec2[i] for i in range(len(vec1))] )
# list comprehension can be applied to complex expression and nested funcs
print( [str(round(355/113, i)) for i in range(1, 6)] )
# Nested comprehensions can do even more fun stuff
mat = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
    ]
print(mat)
# Swap rows and columns with a comprehension, read from right to left
print( [[row[i] for row in mat] for i in [0, 1, 2]] )
# A verbose version of this snippet shows the flow explicitly:
for i in [0, 1, 2]:
    for row in mat:
        print(row[i], end=", ")
    print()
# In the real world, built-in functions beat complex statements though.
print( list(zip(*mat)) )
