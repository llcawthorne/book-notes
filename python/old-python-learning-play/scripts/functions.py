#!/usr/bin/env python3
# a simple output function that takes one argument
def fib(n):
    """Print a Fibonacci series up to n."""
    a, b = 0, 1
    while b < n:
        print(b, end=' ')
        a, b = b, a+b
    print()

# a function that returns a list
def fib2(n):
    """Return a list containing the Fibonacci series up to n."""
    result = []
    a, b = 0, 1
    while b < n:
        result.append(b)
        a, b = b, a+b
    return result

# a function with default argument values
def ask_ok(prompt, retries=4, complaint='Yes or no, please!'):
    """Prompts user for yes or no input"""
    while True:
        ok = input(prompt)
        if ok in ('y', 'ye', 'yes', 'Y', 'Ye', 'Yes'):
            return True
        if ok in ('n', 'no', 'nop', 'nope', 'N', 'No'):
            return False
        retries = retries - 1
        if retries < 0:
            raise IOError('refusenik user')
        print(complaint)

# a function with various keyword arguments
def parrot(voltage, state='a stiff', action='voom', type='Norwegian Blue'):
    """Do a parrot sketch"""
    print("-- This parrot wouldn't", action, end=' ')
    print("if you put", voltage, "volts through it.")
    print("-- Lovely plumage, the", type)
    print("-- It's", state, "!")

# this function uses *parameter and **parameter
# *arguments is simply a list (unpacked)
# **keywords is an unpacked dictionary
def cheeseshop(kind, *arguments, **keywords):
    """The classic cheeseshop sketch"""
    print("-- Do you have any", kind, "?")
    print("-- I'm sorry, we're all out of", kind)
    # this could be:  for arg in arguments: print(arg)
    for arg in arguments: 
        print(arg)
    print("-" * 40)     # print 40 -'s to separate off next part
    # order is not defined unless you sort the keys
    keys = sorted(keywords.keys())
    for kw in keys: 
        print(kw, ":", keywords[kw])

# arbitrary argument lists (UNCOMMON)
# the args list will scoop up all non-keyword arguments
# you could optionally place specific arguments before it though
# like concat(sep, *args) #if you always wanted to specify sepf
def concat(*args, sep="/"):
    """Concatenates multiple arguments separated by sep"""
    return sep.join(args)

# lamba forms are functions restricted to a single line
def make_incrementor(n):
    """Lamba forms are in demand!"""
    return lambda x: x + n

# docstrings can be multi-line
def my_function():
    """Do nothing, but document it.

    No, really, it doesn't do anything.
    """
    pass

# more aboot docstrings
def doc_string():
    """This line should be a short, concise summary of the object's purpose.

    The line before this should always be blank (if it exists at all).  
    The first line should begin with a capital and end with a period.
    Here, should it exist, has one or more paragraphs describing the
    object's calling conventions, its side effects, etc.  Note that
    identation is not stripped from this paragraph.
    """
    pass    # pass does nothing

fib(100)
print(fib2(100))
parrot(1000)
parrot(action = 'VOOOOOOM', voltage = 1000000)
ask_ok("Enter yes or no to continue: ")  # use default for retries & complaint
parrot('a thousand', state = 'pushing up the daisies')
parrot('a million', 'bereft of life', 'jump')
ask_ok("Enter yes or no: ", 2, "C'mon, only yes or no!")
# "Limburger" becomes kind.  "It's very runny, sir." and 
# "It's really very, VERY runn, sir." become arguments
# and all unmapped this=that's become keywords
cheeseshop("Limburger","It's very runny, sir.", \
    "It's really very, VERY runny, sir.",\
    shopkeeper="Michael Palin",
    client="John Cleese",
    sketch="Cheese Shop Sketch")
print()
print(concat("earth","mars","venus"))   # uses default sep
print(concat("earth","mars","venus",sep="."))
print()
# a demonstration of unpacked lists and dictionarys
# you would normally have to type list(range(3,6))
args = [3, 6]
print(list(range(*args)))    # unpacks the list and passes 3,6 to range
print()
# the following is a dictionary.  it can be unpacked and used as keywords
d = {"voltage": "four million", "state":"bleedin' demised", "action":"VOOM"}
parrot(**d)
print()
ask_ok("Enter Ye or Nope: ", 3, "Y or N would work.")
f = make_incrementor(42)
print(f(0))
print(f(1))
print(f(5))
# we can print function documentation
# we access documentation by function.__doc__
print(my_function.__doc__)
print(doc_string.__doc__)
