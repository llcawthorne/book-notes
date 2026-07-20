#!/usr/bin/env python3
"""
 pizzashop.py demononstrates 'has-a' (composition) relationships in oop.

 This program simulates a pizzashop through objects.  A pizzaship is
 composed of ('has-a') Server and Chef [PizzaRobot] from pemployees.py
 and also 'has-a' oven as defined in this file.

 Not only does the file offer a godo representation of composition,
 but it also demonstrates a collection of objects working together to
 simulate a real life situation in an easily graspable fashion.
"""
from pemployees import PizzaRobot, Server

class Customer:
    def __init__(self, name):
        self.name = name
    def order(self, server):
        print(self.name, 'orders from', server)
    def pay(self, server):
        print(self.name, 'pays for item to', server)

class Oven:
    def bake(self):
        print('oven bakes')

class PizzaShop:
    def __init__(self):
        self.server = Server('Pat')     # Embed other objects
        self.chef   = PizzaRobot('Bob') # A robot named bob
        self.oven   = Oven()

    def order(self, name):
        customer = Customer(name)       # Activate other objects
        customer.order(self.server)     # Customer orders from server
        self.chef.work()
        self.oven.bake()
        customer.pay(self.server)

if __name__ == '__main__':
    scene = PizzaShop()                 # Make the composite
    scene.order('Homer')                # Simulate Homer's order
    print('...')
    scene.order('Shaggy')               # Simulate Shaggy's order

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
