#!/usr/bin/env python3
"""
 streams.py: defines Processor, an abstract superclass for stream processing.

 Classes based upon Processor need to define the converter method.
"""

class Processor:
    def __init__(self, reader, writer):
        self.reader = reader
        self.writer = writer
    def process(self):
        while True:
            data = self.reader.readline()
            if not data: break
            data = self.converter(data)
            self.writer.write(data)
    def converter(self, data):
        assert False, 'converter must be defined'

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
