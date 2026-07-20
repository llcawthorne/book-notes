#!/usr/bin/env python3
# Dictionaries are another data type in Python
# They are like arrays, but index by 'keys', which can be any immutable
# type; strings and numbers can always be keys.  Tuples can be keys
# if they contain only strings numbers and tuples.  Lists cannot be keys.
# It is best to think of a dictionary as an unordered set of 
# key: value pairs, with the requirement that keys are unique.

# The main dictionary operations are storing a value with some key and 
# extracting the value given the key.  del can delete a key:value pair.
# list(d.keys()) returns a list of all the keys used in the dictionary
# sorted((d.keys()) does the same, but sorted (where d is the dictionary)
# to check if a single key is in the dictionary, use the in keyword

tel = {'jack': 4098, 'sape': 4139}
tel['guido'] = 4127
print(tel)
print( tel['jack'] )
del tel['sape']
tel['irv'] = 4127
print(tel)
print( list(tel.keys()) )
print( sorted(tel.keys()) )
print( "Guido? ", 'guido' in tel )
print( "Jack?  ", 'jack' in tel )
print( "!Irv?  ", 'irv' not in tel )

# The dict() constructor can build dictionarys from key-value pairs
mydict = dict( [('sape', 4139), ('guido', 4127), ('jack', 4098)] )
print(mydict)
# Keyword pairs work also
mydict = dict(sape=4139, guido=4127, jack=4098)
print(mydict)

# Dict comprehensinos can be used to create dictionarys from 
# arbitrary key and value expressions
mydict2 = {x: x**2 for x in (2, 4, 6)}
print(mydict2)
