#!/usr/bin/env python3

def isprime(y):
    try:
        y = int(y)
    except:
        y = 0

    if y < 2:
        print('Test invalid for inputs under 2!')
        return

    x = 2
    while x <= y // 2:
        if y % x == 0:
            print(y, 'has factor', x)
            break
        x += 1
    else:
        print(y, 'is prime')
