#!/usr/bin/env python3
"""
mydir.py: A module that lists the namespaces of other modules
"""

seplen = 60
sepchr = '-'

def listing(module, verbose=True):
    sepline = sepchr * seplen
    if verbose:
        print(sepline)
        print('name: ', module.__name__, 'file: ', module.__file__)
        print(sepline)
    
    count = 0
    for attr in sorted(module.__dict__):
        print('%02d) %s' % (count, attr), end = ' ')
        if attr.startswith('__'):
            print('<built-in name>')
        else:
            print(getattr(module, attr))
        count += 1

    if verbose:
        print(sepline)
        print(module.__name__, 'has', count, 'names.')
        print(sepline)

if __name__ == '__main__':
    import sys

    if len(sys.argv) == 1:
        import mydir
        listing(mydir)
    else:
        for arg in sys.argv[1:]:
            try:
                exec('import ' + arg)
                listing(eval(arg))
            except:
                print('Error with arg:',arg)

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
