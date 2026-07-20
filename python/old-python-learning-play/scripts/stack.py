#!/usr/bin/env python3
# Uses list functions detailed in list.py
# The concept is simple.  append(x) to push x; pop() to pop last push'd val
stack = [3, 4, 5]
stack.append(6)     # push 6 onto stack
stack.append(7)     # push 7 with append
print(stack)
print(stack.pop())  # pops off 7
print(stack)
print(stack.pop())  # pops off 6
print(stack.pop())  # pops off 5
print(stack)
