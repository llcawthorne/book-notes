#!/usr/bin/env python3
"""
The kitty module implements the Kitty class

The Kitty class extends Person with custom logic for Kitty's
"""

# Do correct import for whether we are doing the package thing
# or interactively.  (There may be a better way for this)
if __name__ == '__main__':
    from person import *
else:
    from .person import *

class Kitty(Person):      # A Kitty "is a" Person
    def __init__(self, name, job='be cute', pay='treats'):
        Person.__init__(self, name, job, pay)
    #  We will mainly be customizing giveRaise handle strings
    def giveRaise(self, *uselessargs):  # Redefinition customizes!
        if (self.pay.split()[0] == 'treats'):
            self.pay = 'more ' + self.pay
        elif (self.pay.split()[0] == 'more'):
            self.pay = 'some ' + self.pay
        elif (self.pay.split()[0] == 'some'):
            self.pay = 'alot more treats'
        elif (self.pay.split()[0] == 'alot'):
            self.pay = (self.pay.split()[0].upper() + ' '
                     + ' '.join(self.pay.split()[1:]) )
        else:
            self.pay += ' and petting'

# Custom testing code
if __name__ == '__main__':
    panther = Kitty('Panther Cawthorne')
    print(panther)
    for x in range (2):
        panther.giveRaise()
    print(panther)
    for x in range(3):
        panther.giveRaise()
    print(panther)

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
