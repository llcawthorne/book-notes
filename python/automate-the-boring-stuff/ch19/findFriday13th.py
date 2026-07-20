#!/usr/bin/env python
# findFriday13th.py - Find the next 10 Friday the 13th's

import datetime

test_day = datetime.datetime.now()
one_day = datetime.timedelta(days=1)
found_holidays = 0

while found_holidays < 10:
    test_day += one_day
    if test_day.strftime("%A %d") == "Friday 13":
        print("Beware!", test_day.strftime("%Y/%m/%d"), "is Friday the 13th!")
        found_holidays += 1
