#!/usr/bin/env python3
"""
classtechniques.py demonstrates several methods of interfacing with
a superclass (Super) in action.  It is a learning tool.
"""
class Super:
    """
    Defines a 'method' and a 'delegate' that expects an 'action' in a subclass.
    """
    def method(self):
        print('in Super.method')    # Default behavior
    def delegate(self):
        self.action()               # Expects action to be
                                    # defined in a subclass
    def action(self):               # Error to call without overriding
        assert False, 'action must be defined!'

class Inheritor(Super):             # Inherit everything verbatim
    """
    Does not provide any new names, so it gets everything defined in Super.
    """
    pass

class Replacer(Super):              # Replace method entirely
    """
    Overrides Super 'method' with a version of its own.
    """
    def method(self):
        print('in Replacer.method')

class Extender(Super):              # Extends method behavior
    """
    Customizes Super 'method' by overriding and calling back to default.
    """
    def method(self):
        print('starting Extender.method')
        Super.method(self)
        print('ending Extender.method')

class Provider(Super):              # provides an 'action' for 'delegate'
    """
    Implements the 'action' method expected by Super 'delegate' method.
    """
    def action(self):
        print('doing a Provider.action')

# Begin test code if ran interactively
if __name__ == '__main__':
    for klass in (Super, Inheritor, Replacer, Extender):
        print('\n' + klass.__name__+ '...')
        klass().method()
    print('\nProvider...')
    x = Provider()
    x.delegate()

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
