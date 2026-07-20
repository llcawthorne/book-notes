# Copyright 2013 Philip N. Klein
from math import sqrt
from mat import Mat
from vec import Vec
import image

"""
This module contains simple procedures to load images
used in the eigenfaces lab.  Before using these procedures, 
obtain and unzip the zip archives faces.zip and unclassified.zip.
These should create subdirectories faces/ and unclassified/,
which should contain the image files.

These procedures use the list-of-lists-of-integers representation
of grayscale images.  This is the representation used by the image module.
"""

def import_faces(path=''):
    "call import_faces() to obtain a list of images of faces"
    faces = {}
    for i in range(1, 21):
        name = path + ('faces/img%02d.png' % i)
        print('Reading '+name)
        faces[i-1] = image.file2image(name)
    return faces

def import_unclassified(path=''):
    "call import_faces() to obtain a list of images of things including faces"
    unclassified = {}
    for i in range(1, 12):
        name = path + ('unclassified/img%02d.png' % i)
        print('Reading '+name)
        unclassified[i-1] = image.file2image(name)
    return unclassified

# Test data
M_d = ({0,1,2},{0,1})
M_f = {(0,0):1/sqrt(2) , (1,0):1/sqrt(2) , (0,1):1/sqrt(3), (1,1):-1/sqrt(3), (2,1):1/sqrt(3)}
test_M = Mat(M_d, M_f)
x_d = {0,1,2}
x_f = {0:10,1:20,2:30}
test_x = Vec(x_d, x_f)
