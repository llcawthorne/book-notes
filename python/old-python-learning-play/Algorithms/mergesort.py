#!/usr/bin/env python

def mergesort(n):
        """Recursively merge sort a list. Returns the sorted list."""
        front = n[:len(n)/2]
        back = n[len(n)/2:]
        
        if len(front) > 1:
                front = mergesort(front)
        if len(back) > 1:
                back = mergesort(back)
        
        return merge(front, back)

def merge(front, back):
        """Merge two sorted lists together. Returns the merged list."""
        result = []
        while front and back:
                # pick the smaller one from the front and stick it on
                result.append(front.pop(0) if front[0]<=back[0] else back.pop(0))
        # add the remaining end
        result.extend(front or back)
        return result

if __name__=="__main__":
    testList = [1,10,9,100,38,15,123,1512561,12,-2]
    sortedList = mergesort(testList)
    print sortedList
