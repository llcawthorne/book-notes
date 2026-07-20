#!/usr/bin/env python3

y = 0

while not y:
    y = input("Enter an integer: ")
    try:
        y = int(y)
    except:
        y = 0

x = y // 2
while x > 1:
    if y % x == 0:
        print(y, 'has factor', x)
        break
    x -= 1
else:
    print(y, 'is prime')
