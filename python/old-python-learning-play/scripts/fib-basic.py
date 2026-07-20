#!/usr/bin/env python3
# Fibonscci Series:
# the sum of two elements defines the next
a, b = 0, 1
while b < 1000:
# print(b, end=' ') ends each line with a space instead of \n
    print(b, end=' ')
    a, b = b, a+b
print()
