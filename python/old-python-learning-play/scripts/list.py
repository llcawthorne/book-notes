#!/usr/bin/env python3
# List objects support the following methods:
# list.append(x)    adds an item to the end of the list; a[len(a):] = [x]
# list.extend(L)    extends the list by appending all the items in the 
#                   given list L; equivalent to a[len(a):] = L
# list.insert(i, x) insert an item at a given position.
#                   i is the index of the element before which to insert
#                   a.insert(0, x) inserts at the front of the list
#                   a.insert(len(a), x) is equivalento a.append(x)
# list.remove(x)    remove the first item from the list whose value
#                   is x.  It is an error if there is no such item.
# list.pop([i])     Remove the item at the given position in the list,
#                   and return it.  If no index is specified, a.pop()
#                   removes and returns the last item in the list.
# Note: the square brackets around the i in the method signature denote
# that the parameter is optional, not that you should type brackets.
# list.index(x)     Return the index in the list of the first item whose
#                   value is x.  It is an error if there is no such item.
# list.count(x)     Return the number of times x appears in the list.
# list.sort()       Sort the items of the list, in place.
# list.reverse()    Reverse the elements of the list, in place.
#
# Examples of lists as stacks and queues are in stack.py and queue.py
# List comprehensions are in comprehension.py
#
# A simple example of many of these follows:
a = [66.25, 333, 333, 1, 1234.5]
print(a)
print("Counts for: 333, 66.25, and 'x'")
print(a.count(333), a.count(66.25), a.count('x'))
a.insert(2, -1)
a.append(333)
print(a)
print("Location of 333:")
print(a.index(333))
a.remove(333)
print(a)
a.reverse()
print(a)
a.sort()
print(a)
