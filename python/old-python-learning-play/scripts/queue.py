#!/usr/bin/env python3
# Uses functions described in list.py
# Simple queue implementation using python lists
# Remember queues are FIFO
# append adds item to back of queue.  pop(0) pops front of queue
queue = ["Eric", "John", "Michael"]
queue.append("Terry")       # Terry goes to back of line
queue.append("Graham")      # Graham is a cracker.  Back of line!
print(queue)
print(queue.pop(0))         # Pops off Eric
print(queue.pop(0))         # John is next
print(queue)
