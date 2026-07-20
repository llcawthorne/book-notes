#!/usr/bin/env python3

class tester:
    def __init__(self, start):
        self.state = start
    def __call_(self, label):
        print(self.state,": ",label)
        self.state += 1

# Example:
# F = tester(0)
# F('spam')  - prints "0: spam"
# F('ham')   - prints "1: spam"
# print(F.state)   - prints "2"
#
# The class preserves state of the counter
# between calls to the function!
