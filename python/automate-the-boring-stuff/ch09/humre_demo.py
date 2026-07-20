#!/usr/bin/env python

import re

from humre import *

phone_regex = exactly(3, DIGIT) + "-" + exactly(3, DIGIT) + "-" + exactly(4, DIGIT)
pattern = re.compile(phone_regex)
match_obj = pattern.search("My number is 415-555-4242")
if match_obj != None:
    print(match_obj.group())
