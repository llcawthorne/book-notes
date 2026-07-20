#!/usr/bin/env python3
# Various examples of useful python programs

import os, glob, sys

def largestInDir(dirname, mask = '*.py'):
    "Find the largest Python source file in a single directory"

    allsizes = []
    allpy = glob.glob(dirname + os.sep + mask)
    for filename in allpy:
        filesize = os.path.getsize(filename)
        allsizes.append((filesize, filename))

    allsizes.sort()
    if allsizes:
        return allsizes[-1]

def largestInTree(dirname, extension = '.py'):
    allsizes = []
    for (thisDir, subsHere, filesHere) in os.walk(dirname):
        for filename in filesHere:
            if filename.endswith(extension):
                fullname = os.path.join(thisDir, filename)
                fullsize = os.path.getsize(fullname)
                allsizes.append((fullsize, fullname))

    allsizes.sort()
    if allsizes: return allsizes[-1]

def largestInPath(extension = '.py'):
    visited = {}
    allsizes = []
    for srcdir in sys.path:
        for (thisDir, subsHere, filesHere) in os.walk(srcdir):
            thisDir = os.path.normpath(thisDir)
            if thisDir.upper() in visited:
                continue
            else:
                visited[thisDir.upper()] = True
            for filename in filesHere:
                if filename.endswith(extension):
                    pypath = os.path.join(thisDir, filename)
                    try:
                        pysize = os.path.getsize(pypath)
                    except:
                        print('skipping',pypath)
                    allsizes.append((pysize, pypath))
    allsizes.sort()
    if allsizes: return allsizes[-1]

if __name__ == '__main__':
    print(largestInDir('/home/cawthorn/programming/python/LearningPython'))
    print(largestInTree('/usr/lib/python2.6'))
    print(largestInTree('/home/cawthorn/programming'))
    print(largestInPath())

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
