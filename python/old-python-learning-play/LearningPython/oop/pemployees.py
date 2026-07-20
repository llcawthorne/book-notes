#!/usr/bin/env python3
"""
 Demononstate 'is-a' relationships (inheritance) in OOP.

 These are employee classes for our theoretical pizza shop.

 Employee is the base class for everything here.
 A Server 'is-a' Employee with default salary and customized work.
 A Chef 'is-a' Employee with default salary option and customized work.
 A PizzaRobot 'is-a' Chef with a customized work action.
"""

class Employee:
    def __init__(self, name, salary=0):
        self.name    = name
        self.salary  = salary
    def giveRaise(self, percent):
        self.salary  = self.salary + int(self.salary * percent)
    def work(self):
        print(self.name, "does stuff")
    def __str__(self):
        return "%s the %s" % (self.name, self.__class__.__name__)
    def __repr__(self):
        return "<Employee: name=%s, salary=%s>" % (self.name, self.salary)

class Chef(Employee):
    def __init__(self, name):
        Employee.__init__(self, name, 50000)
    def work(self):
        print(self.name, "makes food")

class Server(Employee):
    def __init__(self, name):
        Employee.__init__(self, name, 40000)
    def work(self):
        print(self.name, "interfaces with customer")

class PizzaRobot(Chef):
    def __init__(self, name):
        Chef.__init__(self, name)
    def work(self):
        print(self.name, "makes pizza")

if __name__ == "__main__":
    bob = PizzaRobot('bob')         # Make a robot named bob
    print(bob)                      # Run inherited __repr__
    bob.work()                      # Run type specific action
    bob.giveRaise(0.20)             # Give bob a 20% raise
    print(bob); print()

    for klass in Employee, Chef, Server, PizzaRobot:
        obj = klass(klass.__name__)
        obj.work()

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
