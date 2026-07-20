#!/usr/bin/env python3
# Display the use of 'property' with new style classes

class newprops():
    def getage(self):
        if not '_age' in self.__dict__:
            return 40
        else:
            return self._age
    def setage(self, value):
        print('set age:', value)
        self._age = value
    age = property(getage, setage, None, 'How old it be?')

x = newprops()
print(x.age)
x.age = 42
print(x.age)

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
