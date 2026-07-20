#!/usr/bin/env python3

class ListInstance:
    """
    Mix-in class that provides a formatted print() or str() of
    instances via inheritance of __str__, coded here; displays
    instance attrs only; self is the instance of the lowest class;
    uses __X names to avoid clashing with client's attrs
    """
    def __str__(self):
        mysupers = []
        for x in self.__class__.__bases__:
            mysupers.append(''.join(str(x).split('.')[-1][:-2]))
        return '<Instance of %s%s, address %s:\n%s>' % (
                self.__class__.__name__,    # My class's name
                mysupers,                   # My super's
                id(self),                   # My address
                self.__attrnames())         # name=value list
    def __attrnames(self):
        result = ''
        for attr in sorted(self.__dict__):  # Instance attr dict
            result += '\tname %s=%s\n' % (attr, self.__dict__[attr])
        return result

class ListInherited:
    """
    Use dir() to collect both instance attrs and names
    inherited from its classes; Python 3.0 shows more
    names than 2.6  because of the implied object superclass
    in the new-style class model; getattr() fetches inherited
    names not in self.__dict__; use __str__, not __repr__,
    or else this loops when printing bound methods!
    """
    def __str__(self):
        mysupers = []
        for x in self.__class__.__bases__:
            mysupers.append(''.join(str(x).split('.')[-1][:-2]))
        return '<Instance of %s%s, address %s:\n%s' % (
                self.__class__.__name__,    # My class's name
                mysupers,                   # My super's
                id(self),                   # My address
                self.__attrnames())         # Name value list
    def __attrnames(self):
        result =''
        for attr in dir(self):              # Instance dir()
            if attr[:2] != '__':            # Skip internals
                result += '\tname %s=%s\n' % (attr, getattr(self, attr))
        return result

class ListTree:
    """
    Mix-in that returns an __str__ trace of the entire class
    tree and all its objects' attrs at and above self;
    run by print(), str() returns constructed string;
    uses __X attr names t oavoid impacting clients;
    uses generator expr to recurse to superclasses;
    uses str.format() to make substitutions clearer
    """
    def __str__(self):
        mysupers = []
        for x in self.__class__.__bases__:
            mysupers.append(''.join(str(x).split('.')[-1][:-2]))
        self.__visited = {}
        return '<Instance of {0}{1}, address {2}:\n{3}{4}>'.format(
                self.__class__.__name__,
                mysupers,
                id(self),
                self.__attrnames(self, 0),
                self.__listclass(self.__class__, 4))
    def __listclass(self, aClass, indent):
        dots = '.' * indent
        mysupers = []
        for x in aClass.__bases__:
            mysupers.append(''.join(str(x).split('.')[-1][:-2]))
        if aClass in self.__visited:
            return '\n{0}<Class {1}{2}:, address {3}: (see above)>\n'.format(
                    dots,
                    aClass.__name__,
                    mysupers,
                    id(aClass))
        else:
            self.__visited[aClass] = True
            genabove = (self.__listclass(c, indent+4) for c in aClass.__bases__)
            return '\n{0}<Class {1}{2}, address {3}:\n{4}{5}{6}>\n'.format(
                    dots,
                    aClass.__name__,
                    mysupers,
                    id(aClass),
                    self.__attrnames(aClass, indent),
                    ''.join(genabove),
                    dots)
    def __attrnames(self, obj, indent):
        spaces = ' ' * (indent + 4)
        result = ''
        for attr in sorted(obj.__dict__):
            if not attr.startswith('__'):
                result += spaces + '{0}={1}\n'.format(attr, getattr(obj, attr))
        return result

if __name__ == '__main__':

    class Spam(ListInstance):
        def __init__(self):
            self.data1 = 'food'

    class Super:
        def __init__(self):                 # Superclass __init__
            self.data1 = 'spam'             # Create instance attrs
        def ham(self):
            pass

    class SubOne(Super, ListInstance):      # Mix in ham and a __str__
        def __init__(self):                 # lists have access to self
            Super.__init__(self)
            self.data2 = 'eggs'             # More instance attrs
            self.data3 = 42
        def spam(self):                     # Define another method
            pass

    class SubTwo(Super, ListInherited):     # Mix in ham and a __str__
        def __init__(self):                 # lists have access to self
            Super.__init__(self)
            self.data2 = 'eggs'             # More instance attrs
            self.data3 = 42
        def spam(self):                     # Define another method
            pass
        
    class SubTre(Super, ListTree):          # Mix in ham and a __str__
        def __init__(self):                 # lists have access to self
            Super.__init__(self)
            self.data2 = 'eggs'             # More instance attrs
            self.data3 = 42
        def spam(self):                     # Define another method
            pass

    x = Spam()
    print(x)                                # Print __str__ frm ListInstance

    x = SubOne()                           
    print(x)                                # Print __str__ from ListInherited

    x = SubTwo()                           
    print(x)                                # Print __str__ from ListTree

    x = SubTre()                           
    print(x)                                # Print __str__ from ListInstance

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
