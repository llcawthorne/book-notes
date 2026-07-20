#!/usr/bin/env python3

while True:
    reply = input('Enter number: ')
    if reply == 'stop': break
    try:
        num = int(reply)
    except:
        print('Bad!' *8)
    else:
        print(int(reply) ** 2)
print('Bye!')

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
