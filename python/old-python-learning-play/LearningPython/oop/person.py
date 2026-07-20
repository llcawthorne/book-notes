#!/usr/bin/env python3
"""
This module stores the Person class.

Person is a simple class to represent a person and demonstrate basic principles
of object-oriented programming in Python.
"""
from classtools import AttrDisplay      # Use generic display tool

class Person(AttrDisplay):
    """
    Create an process person records
    """
    # Constructor takes up to three objects.  'job' and 'pay' have defaults
    def __init__(self, name, job=None, pay=0): 
        self.name = name     # Fill out fields when created
        self.job  = job      # self is the new instance object
        self.pay  = pay
# This was the __str__ used before AttrDisplay
# It looks nicer, but the new way displays reusability in action!
# Personally..  I would use a prettier '__str__' and use
# what we did in classtools for __repr__.
# I moved the __repr__ def to classtools also.

#    def __str__(self):       # __str__ is called by str() & print()
#        return '[Person: %s, %s]' % (self.name, self.pay)
#    def __repr__(self):      # __repr__ is at interactive prompt
#        # We're just going to call __str__ from repr to keep it simple
#        # __repr__ is not coded as often as __str__ or __init__
#        return self.__str__()
    def lastName(self):
        return self.name.split()[-1]
    def giveRaise(self, percent):
        # the 'int' call keeps our pay value as an integer
        self.pay = int(self.pay * (1 + percent))

# Begin test code
if __name__ == '__main__':
    bob = Person('Bob Smith')   # Automatically invokes __init__
    sue = Person('Sue Jones', job='dev', pay=100000)
    print (bob.name, bob.pay)   # Fetch attached attributes
    print (sue.name, sue.pay)   # sue's and bob's attrs differ
    print(bob.lastName(), sue.lastName())   # Use new methods
    sue.giveRaise(.10)
    print(sue.pay)
    print(bob)                  # Try out __str__ method
    print(sue)                  # by printing with an instance

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
