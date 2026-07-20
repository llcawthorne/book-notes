#!/usr/bin/env python3
from datetime import date
now = date.today()
print(now)
print ( now.strftime("%m-%d-%y. %d %b %Y is a %A on the %d day of %B.") )

birthday = date(1977, 4, 7)
age = now - birthday
print(age.days)
