#!/usr/bin/env python3
"""
Counts lines and chars in a file.
Similar in spirit to wc
"""

def countLines(filename):
    count = 0
    for line in open(filename):
        count += 1
    return count

def countChars(filename):
    count = 0
    for line in open(filename):
        count += len(line)
    return count

def test(filename):
    print('filename:', filename)
    print('lines:',countLines(filename),' chars:',countChars(filename))

if __name__ == '__main__':
    import sys
    if len(sys.argv) == 1:
        test('mymod.py')
    else:
        for arg in sys.argv[1:]:
            try:
                test(arg)
            except:
                print('error in arg:',arg)

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
