#!/usr/bin/env python3
# This is like fib-basic.py, but uses a function for the calculation
def fib(n):     # write Fibonacci series up to n
    """Print a Fibonacci series up to n."""
    a, b = 0, 1
    while b < n:
        print(b, end=' ')
        a, b = b, a+b
    print()

fib(2000)
