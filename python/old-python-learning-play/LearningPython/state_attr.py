#!/usr/bin/env python3
# create an attribute of our function on the fly to track state

def tester(start=0):
    def nested(label):
        print(nested.state, ": ", label)
        nested.state += 1
    nested.state = start
    return nested

# Example:
# F = tester(0)
# F('spam')  - prints "0: spam"
# F('ham')   - prints "1: spam"
# print(F.state)   - prints "2"
#
# The attribute preserves state of the counter
# between calls to the function!
