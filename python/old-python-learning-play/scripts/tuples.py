#!/usr/bin/env python3
# Tuples are sort of like immutable lists
# They are declared like lists without brackets
t = 12345, 54321, 'hello!'
tsingle = 12345,
tempty = ()
print(len(tempty), "     ", tempty)
print(len(tsingle),"     ",tsingle)
print(len(t),"     ",t)
# Tuples may be nested
u = t, 1, 2, 3, (1, 2, 3, 4, 5)
print(len(u), "     ",u)
# Tuples can be unpacked (3 items in t):
# Sequence unpacking works for any sequence and requires that 
# there are as many variables on the left side of the equals sign
# as there are elements in the sequence.
x, y, z = t
print("x, y, z: ", x, "",  y, "", z)
