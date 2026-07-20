#!/usr/bin/env python3
# This is like fib.py, but the function returns a list
def fib(n):     # return Fibonacci series up to n
    """Return a list with Fibonacci series up to n."""
    result = []
    a, b = 0, 1
    while b < n:
        result.append(b)    # uses append method of list object
        a, b = b, a+b
    return result

f2000 = fib(2000)       # call the function and return result to f2000 list
print(f2000)            # print results
# OR
print(fib(2000))
