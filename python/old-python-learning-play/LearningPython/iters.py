#!/usr/bin/env python3
"Defines a user-defined iterator class that generates squares"

class Squares:
    """
    Squares uses a simple method of handling iterators.

    It will only support one iterator at a time (itself), rather
    than multiples with seperate locations.
    The iterator is also 'one-shot.'  One pass and it empties.
    This is fine in a number of situations.
    """
    def __init__(self, start, stop):    # Save state when created
        self.value = start -1
        self.stop  = stop
    def __iter__(self):                 # Get iterator object on iter
        return self
    def __next__(self):                 # Return a square on each iteration
        if self.value == self.stop:     # Also called by next built-in
            raise StopIteration
        self.value += 1
        return self.value **2

class SkipIterator:
    "A separate iterator class to handle multiple loops."
    def __init__(self, wrapped):
        self.wrapped = wrapped          # Iterator state informatoin
        self.offset  = 0
    def __next__(self):
        if self.offset >= len(self.wrapped):  # Terminate iterations
            raise StopIteration
        else:
            item = self.wrapped[self.offset]  # else return and skip
            self.offset += 2
            return item

class SkipObject:
    "Wraps an object to work with SkipIterator(s)"
    # Notice: no __next__ required in this class
    def __init__(self, wrapped):        # Save item to be used
        self.wrapped = wrapped
    def __iter__(self):
        return SkipIterator(self.wrapped)     # New iterator each time

class Iters:
    "Displays trace methods in various overloaded methods"
    def __init__(self, value):
        self.data = value
    def __getitem__(self, i):           # Fallback for iteration
        print('get[%s]:' % i, end='')    # Also for index, slice
        return self.data[i]
    def __iter__(self):                 # Preferred for iteration
        print('iter=> ', end='')         # Allows only one active iterator
        self.ix = 0
        return self
    def __next__(self):
        print('next: ', end='')
        if self.ix == len(self.data): raise StopIteration
        item = self.data[self.ix]
        self.ix += 1
        return item
    def __contains__(self, x):          # Preferred for 'in'
        print('contains: ', end='')
        return x in self.data

if __name__ == '__main__':

    # demonstrating Squares
    for i in Squares(1,5):              # for call iter, which calls __iter__
        print(i, end=' ')               # Each iteration calls __next__
    print()

    # demonstrating SkipObject
    print('-'*60)
    skipper = SkipObject('abcdef')      # Make container object
    I = iter(skipper)                   # Make iterator on it
    print(next(I), next(I), next(I))    # Visit offsets 0, 2, 4

    for x in skipper:       # for calls __iter__ automatically
        for y in skipper:   # Nested for calls __iter__ again
            print(x + y, end=' ')       # Each iter has its own offset & state
    print()

    # demonstrating Iters
    print('-'*60)
    X = Iters([1, 2, 3, 4, 5])          # Make instance of Iters
    print(X[0], X[2])                   # __getitem__
    print(X[0:3])                       # also __getitem__
    print(3 in X)                       # Membership
    for i in X:                         # For loops
        print(i, end=' | ')

    print()
    print([i ** 2 for i in X])          # Other iteration contexts
    print( list(map(bin, X)) )

    I = iter(X)                         # Manual iteration
    while True:
        try:
            print(next(I), end=' @ ')
        except StopIteration:
            break

    print()


# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
