#!/usr/bin/env python3

class MyClass:
    """A simple example class."""
    i = 12345
    def f(self):
        return 'hello world'

class Complex:
    """Simulates complex numbers."""
    def __init__(self, realpart, imagpart):
        self.r = realpart
        self.i = imagpart

class Bag:
    """A bag class that calls internal methods."""
    def __init__(self):
        self.data = []
    def add(self, x):
        self.data.append(x)
    def addtwice(self, x):
        self.add(x)
        self.add(x)

class Sack(Bag):
    """A sack class that inherits from Bag."""
    def __init__(self):
        Bag.__init__(self)
        self.type = "Sack"
        self.rip = 0
    # function and data names must differ!
    def rips(self):
        self.rip = self.rip + 1

class Reverse:
    """Iterator for looping over a sequce backwards"""
    def __init__(self, data):
        self.data = data
        self.index = len(data)
    def __iter__(self):
        return self
    def __next__(self):
        if self.index == 0:
            raise StopIteration
        self.index = self.index - 1
        return self.data[self.index]

class IterSack(Sack):
    """A IterSack is an iterable sack."""
    def __init__(self):
        Sack.__init__(self)
        self.index = 0
        self.count = 0
    def __iter__(self):
    # if your class defines __next__, then __iter__ can return self
        self.index = self.count
        return self
    def __next__(self):
        if self.index == 0:
            raise StopIteration
        self.index = self.index - 1
        return self.data[self.index]
    def add(self, x):
        Bag.add(self, x)
        self.count = self.count + 1
    def addtwice(self, x):
        Bag.addtwice(self, x)
        self.count == self.count +2

class Struct:
    """An empty class can serve as a poor man's struct"""
    pass

# a simple function based generator
def reverse(data):
    for index in range(len(data)-1, -1, -1):
        yield data[index]

# Very simple class
x = MyClass()
print(x.__doc__)
print(x.i)
print(x.f())

# functions can be re-aliases
xf = x.f
print(xf())

# __init__ takes parameters
x = Complex(3.0, -4.5)
print(x.r, ",", x.i)

# variables spring into existence in python, even in classes
x.counter = 1
while x.counter < 10: 
    x.counter = x.counter * 2
print(x.counter)
del x.counter

x = Bag()
y = Bag()
print('x', x.__class__, x.data, 'y', y.__class__, y.data)
x.add("tomato")
x.add("lettuce")
x.add("cucumber")
y.addtwice("H2O")
y.add("mt dew")
# notice the lack of encapsulation, but each does have a separate list
print(x.data)
print(y.data)

z = Sack()
print('z', z.__class__, z.data)
z.addtwice("lootz")
z.add("lolz")
z.addtwice("heavy stuff")
z.rips()
print(issubclass(Sack, Bag), isinstance(z, Bag), isinstance(z, Complex))
print(z.type, 'has', z.rip, 'rips and contains:')
print(z.data)

x = Struct()
x.name = 'John'
x.dept = 'Computer Lab'
x.salary = 1000
print(x.name, x.dept, x.salary)

for char in Reverse('spam'):
    print(char, end=' ')
print()

z = IterSack()
z.addtwice("Jermaine")
z.add("Michael")
z.addtwice("Latoya")
z.rips()
for item in z:
    print(item, end = " ")
print()
for item in z:
    print(item, end = " ")
print()

# note in the earlier code how much easier it was to implement this
# generator compared to writing __iter__ and __next__ for a class
for char in reverse('golf'):
    print(char, end=' ')
print()
