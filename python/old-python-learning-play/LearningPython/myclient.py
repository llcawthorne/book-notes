#!/usr/bin/env python3
"""
Import a module an use its functions
"""
import mypkg.mymod as M

print(M.countLines('mymod.py'))
print(M.countChars('mymod.py'))
M.test('mymod.py')

# Now try with from
from mymod import *

print('')
print(countLines('mymod.py'))
print(countChars('mymod.py'))
test('mymod.py')

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
