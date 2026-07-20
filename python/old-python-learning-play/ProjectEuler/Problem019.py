#!/usr/bin/env python3
"""Project Euler Problem 019


You are given the following information, but you 
may prefer to do some research for yourself.

    * 1 Jan 1900 was a Monday.
    * Thirty days has September,
      April, June and November.
      All the rest have thirty-one,
      Saving February alone,
      Which has twenty-eight, rain or shine.
      And on leap years, twenty-nine.
    * A leap year occurs on any year evenly divisible by 4, but not on a century 
      unless it is divisible by 400.

How many Sundays fell on the first of the month during the twentieth 
century (1 Jan 1901 to 31 Dec 2000)?
"""

Jan =  31
Feb =  28
Mar =  31
Apr =  30
May =  31
Jun =  30
Jul =  31
Aug =  31
Sep =  30
Oct =  31
Nov =  30
Dec =  31

janDone = febDone = marDone = aprDone = mayDone = junDone = False
julDone = augDone = sepDone = octDone = novDone = decDone = False

day = 0        # Monday, 1 Jan 1900
weekday = 0    # Monday is 0
year = 1900
count = 0

# No more than 366 days in a year.  No more than 101 years.
for x in range(568000):
    if year % 4 == 0 and (year % 100 != 0 or year % 400 == 0):
        leap = 1
    else:
        leap = 0


    if(day >= Jan and not janDone):
        day = day - Jan
        janDone = True
    elif(day >= Feb + leap and janDone and not febDone):
        day = day - Feb - leap
        febDone = True
    elif(day >= Mar and janDone and febDone and not marDone):
        day = day - Mar
        marDone = True
    elif(day >= Apr and janDone and febDone and marDone and not aprDone):
        day = day - Apr
        aprDone = True
    elif(day >= May 
            and janDone and febDone and marDone and aprDone
            and not mayDone):
        day = day - May
        mayDone = True
    elif(day >= Jun and not junDone
            and janDone and febDone and marDone and aprDone
            and mayDone):
        day = day - Jun
        junDone = True
    elif(day >= Jul and not julDone
            and janDone and febDone and marDone and aprDone
            and mayDone and junDone):
        day = day - Jul
        julDone = True
    elif(day >= Aug and not augDone
            and janDone and febDone and marDone and aprDone
            and mayDone and junDone and julDone): 
        day = day - Aug
        augDone = True
    elif(day >= Sep 
            and janDone and febDone and marDone and aprDone
            and mayDone and junDone and julDone and augDone
            and not sepDone):
        day = day - Sep
        sepDone = True
    elif(day >= Oct and not octDone
            and janDone and febDone and marDone and aprDone
            and mayDone and junDone and julDone and augDone and sepDone):
        day = day - Oct
        octDone = True
    elif(day >= Nov 
            and janDone and febDone and marDone and aprDone
            and mayDone and junDone and julDone and sepDone
            and octDone and augDone and not novDone):
        day = day - Nov
        novDone = True
    elif(day >= Dec
            and janDone and febDone and marDone and aprDone
            and mayDone and junDone and julDone and sepDone
            and augDone and octDone and novDone):
        day = 0
        year += 1
        print(year)
        janDone = febDone = marDone = aprDone = mayDone = junDone = False
        julDone = augDone = sepDone = octDone = novDone = decDone = False

    day += 1
    weekday = ((weekday + 1) % 7) 

    if year > 1900 and year < 2001:
        if day == 1 and weekday == 6:
            count += 1


print(year, weekday, day, x)
print("The bloody count is",count)
