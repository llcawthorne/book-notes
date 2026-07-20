#!/usr/bin/env python3

while True:
    reply = input('Enter number: ')
    if reply == 'stop': 
        break
    elif reply.isdigit() :
        print(int(reply) ** 2)
    else:
        print('Try again!')
print('Bye!')

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
