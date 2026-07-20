#!/usr/bin/env python3
"Assorted class utilities and tools"

class AttrDisplay:
    """
    Provides an inheritable print overload method that displays
    instances with their class names and a name=value pair for
    each attribute stored in the instance itself (but not attrs
    inherited from its classes).  Can be mixed into any class,
    and will work on any instance.
    """
    def __gatherAttrs(self):
        attrs = []
        for key in sorted(self.__dict__):
            attrs.append('%s=%s' % (key, getattr(self, key)))
        return ', '.join(attrs)
    # If we do not redefine __str__ classes based on this will call __repr__
    def __repr__(self):
        """
        This __repr__ displays all attributes native to an instance.
        It is functional, but not particularly attractive.
        """
        return '[%s: %s]' % (self.__class__.__name__, self.__gatherAttrs())

if __name__ == '__main__':
    class TopTest(AttrDisplay):
        count = 0
        def __init__(self):
            self.attr1 = TopTest.count
            self.attr2 = TopTest.count+1
            TopTest.count += 2
        def setAttr1(self, val):
            self.attr1 = val
        def setAttr2(self, val):
            self.attr2 = val
    class SubTest(TopTest):
        pass

    X, Y, Z = TopTest(), TopTest(), SubTest()
    print(X)
    print('-'*60)
    print(Y)
    print('-'*60)
    print(Z)

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
