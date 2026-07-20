#!/usr/bin/env python3
import sys

def this_fails():
    x = 1 / 0

def divide(x, y):
    try:
        result = x / y
    except ZeroDivisionError:
        print("division by zero attempted!")
    else:
        print("result is", result)
    finally:
        print("executing finally clause")

# Three user-defined exceptions
class Error(Exception):
    """Base class for exceptions in this module."""
    pass

class InputError(Error):
    """Exception raised for errors in the input.

    Attributes:
        expression -- input expression in which the error occurred
        message -- explanation of the error
    """

    def __init__(self, expression, message):
        self.expression = expression
        self.message = message

class TransitionError(Error):
    """Raised when an operation attempts a state transition that's not 
    allowed.

    Attributes:
        previous -- state at beginning of transition
        next -- attempted new state
        message -- explanation of why the specific transition is not allowed
    """

    def __init__(self,previous, next, message):
        self.previous = previous
        self.next = next
        self.message = message

class B(Exception):
    pass
class C(B):
    pass
class D(C):
    pass

# begin excecution here
# The following prints B, C, D.  If the except clauses were reversed,
# it would print B, B, B.  Because D is a C, and C is a B.  B does not
# match except D:, but D matches except B:
for c in [B, C, D]:
    try:
        raise c()
    except D:
        print("D")
    except C:
        print("C")
    except B:
        print("B")

while True:
    try:
        x = int(input("Please enter a number: "))
        break
    except ValueError:
        print("Oops! That was no valid number.  Try again...")

try:
    f = open('myfile.txt', 'w')
    f.write("{0}\n".format(x))
    f.write("{0}\n".format(x+1))
    f.write("{0}\n".format(x+10))
except IOError as err:
    print("I/O error: {0}".format(err))
finally:
# finally works well for releasing real-world resources
# ie. files, network connections, etc
    f.close()

try:
    this_fails()
except ZeroDivisionError as err:
    print("Handling run-time error:", err)

divide(5,2)
divide(5,0)

try:
    f = open('myfile.txt')
    s = f.readline()
    i = int(s.strip())
except IOError as err:
    print("I/O error: {0}".format(err))
except ValueError:
    print("Could not convert data to an integer.")
except:
    print("Unexpected error:", sys.exc_info()[0])
    # Raise re-raises the unhandled exception
    raise
else:
    f.seek(0)
    print("myfile.txt has", len(f.readlines()), "lines")
finally:
    f.close()

print("The first value in myfile is:", s)

print("A handled user defined exception:")
try:
    raise TransitionError('gas','solid',"gas to solid not allowed!")
except TransitionError as err:
    print("Transition Error: ", err.message)

print("An unhandled user defined exception:")
raise InputError("cin >> joe", "Joe not defined!")
