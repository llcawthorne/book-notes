#!/usr/bin/env python3
"""
The department module implements the Department class

The Department is a container for Person (and Manager) objects
"""

from person import Person
from manager import Manager

class Department:
    def __init__(self, *args):
        self.members = list(args)
    def addMember(self, person):
        self.members.append(person)
    def giveRaises(self, percent):
        for person in self.members:
            person.giveRaise(percent)
    def showAll(self):
        for person in self.members:
            print(person)

if __name__ == '__main__':
    bob = Person('Bob Jones', job='Scripter', pay=35000)
    sue = Person('Sue Jenkins', job='Web Gal', pay=20000)
    jay = Person('Jay Moretz', job='Server Admin', pay=30000)
    tom = Manager('Tom Strut', pay=60000)
    jim = Manager('Jim Timmons', job='CIO', pay=250000)

    development = Department(bob, sue, tom)
    development.showAll()
    print('-'*60)
    for new in (jay, jim):
        development.addMember(new)
    development.giveRaises(.10)
    development.showAll()

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
