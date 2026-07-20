#!/usr/bin/env python3
s = 'Hello, world.'
print( "Str: ", str(s) )
print( "Repr:", repr(s) )
print( "Str: ", str(1.0/7.0) )
print( "Repr:", repr(1.0/7.0) )
x = 10 * 3.25
y = 200 * 200
s = 'The value of x is ' + str(x) + ', and y is ' + str(y) + '...'
print(s)
r = 'The value of x is ' + repr(x) + ', and y is ' + repr(y) + '...'
print(r)
# The repr() of a string adds string quotes and backslashes:
hello = 'hello, world\n'
hellos = str(hello)
hellor = repr(hello)
print("Str: ", hellos)
print("Repr:", hellor)
# The argument to repr() may be any Python object:
print( repr({x, y, ('spam', 'eggs')}) )
