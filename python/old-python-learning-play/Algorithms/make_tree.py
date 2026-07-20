#!/usr/bin/env python3
# Make tree from inorder and postorder traversal

# Implemented this for fun
# Follows the Problem 4.4.7 Algorithm and seems to work

class SimpleNode:
    def __init__(self,value):
        self.value  = value
        self.left   = None
        self.right  = None
    def printVal(self):
        print(self.value,end=' ')
    def printIO(self):
        if self.left != None: self.left.printIO()
        self.printVal()
        if self.right != None: self.right.printIO()
    def printPO(self):
        if self.left != None: self.left.printPO()
        if self.right != None: self.right.printPO()
        self.printVal()
    def printPR(self):
        self.printVal()
        if self.left != None: self.left.printPR()
        if self.right != None: self.right.printPR()

def MakeTree(IO,PO):
    # Handle base cases here
    if IO == [] and PO == []: return
    elif IO == []: print("Invalid input!"); exit()
    elif PO == []: print("Invalid input!"); exit()
    elif len(PO)>1 and IO[-1]==PO[-1]: print("Invalid input!"); exit()

    root = SimpleNode(PO[-1])
    leftIO,rightIO,leftPO,rightPO = [],[],[],[]
    idx = 0
    while IO[idx] != root.value:
        leftIO.append(IO[idx])
        idx += 1
    idx+=1
    while idx < len(PO):
        rightIO.append(IO[idx])
        idx+=1
    for value in PO:
        if value in leftIO:
            leftPO.append(value)
        elif value in rightIO:
            rightPO.append(value)
    root.left  = MakeTree(leftIO,leftPO)
    root.right = MakeTree(rightIO,rightPO)
    return root

if __name__ == '__main__':
   testList = MakeTree([9,3,1,0,4,2,7,6,8,5],[9,1,4,0,3,6,7,5,8,2])
   testList.printIO()
   print()
