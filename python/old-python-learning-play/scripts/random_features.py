#!/usr/bin/env python3
# A simple introduction to random functions
import random
print( random.choice(['apple', 'pear', 'banana']) )

samps = random.sample(range(100), 10)   # 10 samples w/o replacement
print(samps)

print( random.random() )                # a random float

die = random.randrange(6)             # random int from range(6)
die = die + 1
print("The die is cast: ", die)
