#!/usr/bin/env python3
"""
The answer is: 
    fill jug3, pour into jug5
    fill jug3, fill jug5 with jug3; using 2 and leaving 1 in jug3
    empty jug5
    add the 1 left in jug3 to jug5
    fill jug3; pour jug3 into jug5
    STOP: you now have 4 gallons in the 5 gallon jug (jug5)
"""

import random

class Jug:
    """A jug to hold water"""
    def __init__(self, cap):
        self.capacity = cap
        self.current  = 0
    def fill(self):
        self.current = self.capacity
    def transfer(self, other):
        if (self.current + other.current) < other.capacity:
            other.current += self.current
        else:
            self.current -= other.capacity - other.current
            other.current = other.capacity
    def empty(self):
        self.current = 0

if __name__=='__main__':
    jug3 = Jug(3)
    jug5 = Jug(5)
    loopC = 0
    
    print("Begin manual trial...")
    jug3.fill()
    jug3.transfer(jug5)
    jug3.fill()
    jug3.transfer(jug5)
    jug5.empty()
    jug3.transfer(jug5)
    jug3.fill()
    jug3.transfer(jug5)
    print("Jug 5 has",jug5.current,"from manual filling.")
    print()

    "This way is much less efficient, but finds the answer itself."
    print("Begin random trial...")
    jug3.empty()
    jug5.empty()
    while jug5.current != 4:
        loopC += 1
        rInt = random.randint(1,6)
        "There is a more Pythonic way to do this, but I cannot remember."
        "I have gotten spoiled using (cond) and switch(var)"
        if rInt==1:
                jug3.fill()
        elif rInt==2:
                jug5.fill()
        elif rInt==3:
                jug3.transfer(jug5)
        elif rInt==4:
                jug5.transfer(jug3)
        elif rInt==5:
                jug3.empty()
        elif rInt==6:
                jug5.empty()

    print("We looped",loopC,"times")
    print("Jug 5: ",jug5.current," Done")
