#!/usr/bin/env python3
# File: dbdemo.py: display Person objects on a shelve database

# We do not have to import Person and Manager classes manually!
import shelve

db = shelve.open('persondb')        # Reopen the shelve

print('There are',len(db),'records.')
for key in sorted(db):
    print(key,'=>',db[key])         # Will call the objects __str__

print('-'*60)
bob = db['Bob Smith']               # Key is .name attribute
print(bob.name,'has lastname',bob.lastName())   # other methods work

db.close()

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
