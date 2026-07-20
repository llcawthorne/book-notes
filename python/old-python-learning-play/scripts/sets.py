#!/usr/bin/env python3
# Python includes a data type for sets. 
# A set is an unordered collection with no duplicate elements.
# Basic uses include membership testing and eliminating duplicate entries.
# Set objects support union, intersection, difference, and symmetric diff.
#
# Curly braces or the set() function can be used to create sets
# To create an empty set you must used the set() function.

basket = {'apple', 'orange', 'apple', 'pear', 'orange', 'banana'}
print(basket)
# Make a list
fruit = ['apple', 'orange', 'apple', 'pear', 'orange', 'banana']
print(fruit)
# Make the list into a set
fruit = set(fruit)
print(fruit)
fruit = {'orange','apple'}
print(fruit)
print( "Show me orange: ", 'orange' in fruit )    # Fast membership testing
print( "Show me crabgrass: ", 'crabgrass' in fruit )

# Demonstrate set operations on unique letters from two words
a = set('abracadabra')
b = set('alacazam')
print("A, B, Diff, Union, Intersection, Symmetric Diff, !abc in A")
print(a)            # Unique letters in a
print(b)            # Unique letters in b
print(a - b)        # Letters in a but not in b (difference)
print(a | b)        # Letters in a or b (union)
print(a & b)        # Letters in a and b (intersection)
print(a ^ b)        # Letters in a or b but not both (xor - symmetric diff)

# There are also comprehsnions of sets
a = {x for x in 'abracadabra' if x not in 'abc'}
print(a)
