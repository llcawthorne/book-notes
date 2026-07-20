#!/usr/bin/env python3
"""
 proc_converters.py: defines some converters based upon Processor
 defined in proc_streams.py
"""
from proc_streams import Processor

class Uppercase(Processor):
    def converter(self, data):
        return data.upper()

class HTMLize(Processor):
    def converter(self, data):
        return '<PRE>%s</PRE>\n' % data.rstrip()

if __name__ == '__main__':
    import sys
    obj = Uppercase(open('spam.txt'), sys.stdout)
    obj.process()

    print('-'*60)
    obj = HTMLize(open('spam.txt'), sys.stdout)
    obj.process()

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
