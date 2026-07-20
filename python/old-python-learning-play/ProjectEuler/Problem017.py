#!/usr/bin/env python3
"""Project Euler Problem 017

If the numbers 1 to 5 are written out in words: 
one, two, three, four, five, then there are 
3 + 3 + 5 + 4 + 4 = 19 letters used in total.

If all the numbers from 1 to 1000 (one thousand) 
inclusive were written out in words, how many 
letters would be used? 
"""

count = 0
for x in range(1,1001):
    if x // 1000:
        count += len("onethousand")
        x -= 1000
    if x >= 900:
        count += len("ninehundredand")
        x -= 900
        if x == 0: count -= 3
    if x >= 800:
        count += len("eighthundredand")
        x -= 800
        if x == 0: count -= 3
    if x >= 700:
        count += len('sevenhundredand')
        x -= 700
        if x == 0: count -= 3
    if x >= 600:
        count += len('sixhundredand')
        x -= 600
        if x == 0: count -= 3
    if x >= 500:
        count += len('fivehundredand')
        x -= 500
        if x == 0: count -= 3
    if x >= 400:
        count += len('fourhundredand')
        x -= 400
        if x == 0: count -= 3
    if x >= 300:
        count += len('threehundredand')
        x -= 300
        if x == 0: count -= 3
    if x >= 200:
        count += len('twohundredand')
        x -= 200
        if x == 0: count -= 3
    if x >= 100:
        count += len('onehundredand')
        x -= 100
        if x == 0: count -= 3
    if x >= 90:
        count += len('ninety')
        x -= 90
    if x >= 80:
        count += len('eighty')
        x -= 80
    if x >= 70:
        count += len('seventy')
        x -= 70
    if x >= 60:
        count += len('sixty')
        x -= 60
    if x >= 50:
        count += len('fifty')
        x -= 50
    if x >= 40:
        count += len('forty')
        x -= 40
    if x >= 30:
        count += len('thirty')
        x -= 30
    if x >= 20:
        count += len('twenty')
        x -= 20
    if x == 19:
        count += len('nineteen')
    elif x == 18:
        count += len('eighteen')
    elif x == 17:
        count += len('seventeen')
    elif x == 16:
        count += len('sixteen')
    elif x == 15:
        count += len('fifteen')
    elif x == 14:
        count += len('fourteen')
    elif x == 13:
        count += len('thirteen')
    elif x == 12:
        count += len('twelve')
    elif x == 11:
        count += len('eleven')
    elif x == 10:
        count += len('ten')
    elif x == 9:
        count += len('nine')
    elif x == 8:
        count += len('eight')
    elif x == 7:
        count += len('seven')
    elif x == 6:
        count += len('six')
    elif x == 5:
        count += len('five')
    elif x == 4:
        count += len('four')
    elif x == 3:
        count += len('three')
    elif x == 2:
        count += len('two')
    elif x == 1:
        count += len('one')
    else:
        count += 0

print('Total count:',count)

