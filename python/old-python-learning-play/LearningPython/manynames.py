#!/usr/bin/env python3
"""
manynames.py: creates X in five different places to demonstrate namespaces.
"""

X = 11          # Global (module) name/attribute (X, or manynames.X)

def f():
    print(X)    # access global X (11)

def g():
    X = 22      # Local (function) variable (X, hides module X)
    print(X)

class C:
    X = 33               # Class attribute (C.X)
    def m(self):
        X = 44           # Local variable in method (X)
        self.X = X + 11  # Instance attribute (instance.X) (44 + 11 = 55)

if __name__ == '__main__':
    print(X)        # 11: module (aka manynames.X outside file)
    f()             # 11: global
    g()             # 22: local
    print(X)        # 11: module name unchanged

    obj = C()       # make instance
    print(obj.X)    # 33: class name inherited by instance

    obj.m()         # attach attribute name X to instance now
    print(obj.X)    # 55: instance
    print(C.X)      # 33: class

    #print(C.m.X)   # FAILS: only visible in method
    #print(g.X)     # FAILS: only visible in function

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
