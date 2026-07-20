#!/usr/bin/env python3
# File: dbupdate.py: update Person objects on a shelve database

import shelve

db = shelve.open('persondb')        # Reopen our shelve

for key in sorted(db):              # Iterate to display db objects
    print(key, '\t=>', db[key])     # Prints with custom format

rec = db['Sue Jones']               # Index by key to fetch
rec.giveRaise(.10)                  # Update using class method
db['Sue Jones'] = rec               # Assign changs back to shelve
db.close()                          # Close to save changes

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
