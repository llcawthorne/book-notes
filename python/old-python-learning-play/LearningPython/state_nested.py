#!/usr/bin/env python3
# only works in Python3

def state_prev(start=0):
    state = start
    def nested(label):
        nonlocal state
        print(state,": ",label)
        state += 1
    return nested

# Example:
# F = tester()
# F('spam')  - prints "0: spam"
# F('ham')   - prints "1: spam"
#
# The nested function preserves state of the counter
# between calls to the function!
