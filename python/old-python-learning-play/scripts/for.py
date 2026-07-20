#!/usr/bin/env python3
# for in python works differently
# it iterates over members of a list or string

# for a string
str = "mojo the jojo"
for x in str:
    print(x, end=' ')
print()

# for a list
a = ['cat', 'window', 'defenestrate']
for x in a:
    print(x, len(x))

# you should not modify what you are iterating over
# for strings, this is a non-issue (they are immutable)
# if you need to with a list, then iterate over a copy like so
for x in a[:]:  # makes a slice copy of the list
# if the item is longer than 6, put a copy at the start of list
    if len(x) > 6: a.insert(0,x)
print(a)

# if you need to iterate over a series of numbers, use range(endpoint)
# note that the endpoint is never part of the range
for i in range(5):
    print(i, end=' ')
print()

# you can also use range(start, endpoint) or range(start, endpoint, step)
for i in range(5, 10):          # 5 through 9
    print(i, end=' ')
print()
for i in range(0, 10, 3):       # 0 to 10 in steps of 3 (0, 3, 6, 9)
    print(i, end=' ')
print()
for i in range(-10, -100, -30): # -10, -40, -70
    print(i, end=' ')
print()

# you can also iterate over the indices of a sequence with range and len
a = ['Mary', 'had', 'a', 'little', 'lamb']
for i in range(len(a)):
    print(i, a[i])

# range creates something of a virtual list.  if you need a real list
# use the range command with list(range(endpoint)).  IE:
a = list(range(5))
for x in a:
    print(x, end=' ')
print()

# finally, for loops can take else clauses that execute when the list
# is exhausted, but not if a break is called from within the loop
for n in range(2, 10):
    for x in range(2, n):
        if n % x == 0:
            print(n, 'equals', x, '*', n//x)
            break
    else:
        # loop fell through without finding a factor
        print(n, 'is a prime number')
