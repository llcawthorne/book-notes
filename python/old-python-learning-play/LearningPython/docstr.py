#!/usr/bin/env python3
# Demonstrats where docstrings can go in a program
# See docstrings.py for more examples
"I am: docstr.__doc__"

def func(args):
    "I am: docstr.func.__doc__"
    pass

class spam:
    "I am: spam.__doc__ or docstr.spam.__doc__"
    def method(self, arg):
        "I am: spam.method.__doc__ or self.method.__doc__"
        pass

if __name__ == '__main__':
    import docstr

    print(docstr.__doc__)
    print(docstr.func.__doc__)
    print(docstr.spam.__doc__)
    print(docstr.spam.method.__doc__)

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
