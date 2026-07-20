#!/usr/bin/env python3
"trace.py: defines a wrapper class that traces calls to a wrapped object."

class wrapper:
    def __init__(self, object):
        self.wrapped = object                   # Save object
    def __getattr__(self, attrname):
        print('Trace:', attrname)               # Trace fetch
        return getattr(self.wrapped, attrname)  # Delegate fetch

if __name__ == '__main__':
    x = wrapper([1,2,3])                        # Wrap a list
    x.append(4)                                 # Delegate to list method
    print(x.wrapped)                            # Print member
    print()
    x = wrapper({'a':1, 'b':2})                 # Wrap a dictionary
    print(x.keys())                             # Delegate to dict method

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
