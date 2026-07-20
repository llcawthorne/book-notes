#!/usr/bin/env python3
# Reading and Writing files in Python makes me happy

# open is commonly used as open(filename, mode) and returns a file object
# f = open('/tmp/workfile', 'w')

# mode can be 'r' for read, 'w' for write (erasing any existing file)
# 'a' for append, 'r+' for reading and writing. 
# if you leave mode blank, 'r' will be assumed
# files are opened in text mode by default.  you append 'b' to the mode
# to open a file in binary mode
# f = open('/tmp/joe.bin', 'rb+') would open joe for binary read-write

# Using our file object - Reading Functions
# f.read() will read the entire file and return it as a string or bytes
# f.read(size) will read size bytes from a file (and return it)
# f.read() returns "" at EOF
# f.readline() reads a single line and returns it with the \n char ending
# f.readline() returns "\n" for blank lines and '' for EOF
# f.readlines() returns a list of all the lines of data in the file
# f.readlines(sizehint) reads sizehint bytes + enough to finish a line
# for loops work well for looping to read lines.  (w/o as much control)  IE:
# for line in f: print(line, end='')    # would print the file line by line

# Using our file object - Writing Functions
# f.write(string) writes a string to a file and returns # of chars written
# to write a non-string, convert it to a string (str())
# f.tell() returns an int giving the file object's current position
#          measured in bytes from the beginning of the file
# f.seek(offset, from_what) changes the file object's position
#          from_what = 0 (beginning of file) | 1 (current) |
#                      2 (end of file)      // defaults to 0 if omitted
# in text files (not opened b), only seeks from_what=0 are allowed
# except f.seek(0, 2) will seek to the file end

# When you are done with a file, always close f.close()

# Pickle makes it easy to work with special object types
import pickle

f = open('/tmp/workfile','w')
f.write("This is a Python written workfile.")
f.write("New Line?")
f.write("\n")
f.write("This I know is a new line.\n")
f.close()

f = open('/tmp/workfile','r')
for line in f:
    print(line, end='')
f.seek(0)
print(f.readline())
f.seek(0)
print(f.readline(5))
f.seek(0)
print(f.read())
f.close()

# the with keyword works well when you just need to open a file,
# read it, and then close it.  it ensures that the file is closed.
with open("/tmp/workfile") as f:
    for line in f:
        print(line, end='')
# f.readline() would crash, because f is closed now

# pickle can be used to store and load special types
# files need to be opened binary
x = 1000
y = 500
z = x + y
L = ['my', 'country', 'tis', 'of', 'thee']
f = open('/tmp/workfile','wb')   # overwrites old workfile
pickle.dump(x, f)
pickle.dump(y, f)
pickle.dump(z, f)
pickle.dump(L, f)
f.close()

f = open('/tmp/workfile', 'rb')
new_x = pickle.load(f)
new_y = pickle.load(f)
new_z = pickle.load(f)
new_L = pickle.load(f)

print('{0:5d} + {1:5d} = {2:5d}'.format(new_x, new_y, new_z))
print(new_L)
