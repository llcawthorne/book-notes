#!/usr/bin/env python3
"""
The manager module implements the Manager class

The manager class extends Person with custom logic for Manager's
"""

from person import Person

class Manager(Person):      # A Manager "is a" Person
    """
    A customized Person with special requirements
    """
    ## This class inherits almost everything from Person!
    #  First let's customize init
    def __init__(self, name, job='Manager', pay=150000):
        Person.__init__(self, name, job, pay)
    #  We will mainly be customizing giveRaise to include a special 10% bonus
    def giveRaise(self, percent, bonus=.10):    # Redefinition customizes!
        Person.giveRaise(self, percent + bonus) # uses most of Person logic

# Custom testing code
if __name__ == '__main__':
    rufus = Manager('Rufus Shinra','President',1000000)
    billy = Manager('Billy Blanks')
    print(rufus , '\t' , rufus.job)
    print(billy)
    # A 10% raise is actually 20% due to the bonus!
    billy.giveRaise(.10)
    print('After raise:',billy)

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
