#!/usr/bin/env python3
# We'll use the format() method of string objects some here
import math
# The tutorial says the next line will work, but it doesn't:
# print( 'We are the {} who say "{}!"'.format('knights', 'Ni') )
# Arguments can be referenced by number
print('{0} and {1}'.format('spam', 'eggs'))
print('{1} and {0}'.format('spam', 'eggs'))
# Or by a keyword name
print('This {food} is {adjective}.'.format(
    food='spam', adjective='absolutely horrible'
    ))
# Positional argument and keyword argument reference can be mixed
print('The story of {0}, {1}, and {other}.'.format(
    'Bill', 'Manfred', other='Georg'
    ))
# '!a', '!s', and '!r' can be used to convert a value before formatting
# ascii(), string(), and repr() are what they correspond to
print('The value of PI is approximately {0}.'.format(math.pi))
print('The value of PI is approximately {0!r}.'.format(math.pi))
# Optionally : followed by a format specifier can be used also
print('The value of PI is approximately {0:.3f}.'.format(math.pi))
# as you see :.3f formats it as a float with 3 decimal places
# {field:int} like {0:5} makes a field at least 5 chars wide
table = {'Sjoerd':4127, 'Jack':4098, 'Dcab':7678}
for name, phone in table.items():
    print('{0:10} ==> {1:10d}'.format(name, phone))
# We can use dictionary keys in a format string also
print('Jack: {0[Jack]:d}; Sjoerd: {0[Sjoerd]:d}; Dcab: {0[Dcab]:d}'.format(
    table))
# Back to PI..  Old style string formatting works still as so:
# Use of old formatting won't last forever.  Recognize it, but try 
# to use the new str.format() methods in your own code
print('The value of PI is approximately %5.3f.' % math.pi)

