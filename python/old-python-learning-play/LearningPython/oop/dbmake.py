#!/usr/bin/env python3
# File: dbmake.py: store Person objects on a shelve database

from person  import Person
from manager import Manager
import shelve

bob = Person('Bob Smith')
sue = Person('Sue Jones', job='dev', pay=100000)
tom = Manager('Tom Jones')

print('Creating database...')
db = shelve.open('persondb')        # open filename where objects are stored
for object in (bob, sue, tom):      # use object's name attr as key
    print(object.name)
    db[object.name] = object        # store object on shelve by key
db.close()                          # close after making changes
print('Database created!')

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
