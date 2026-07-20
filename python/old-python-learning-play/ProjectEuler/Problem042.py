#!/usr/bin/env python3
"""Project Euler Problem 042

The n^(th) term of the sequence of triangle numbers is given by, 
t_(n) = ½n(n+1); so the first ten triangle numbers are:

1, 3, 6, 10, 15, 21, 28, 36, 45, 55, ...

By converting each letter in a word to a number corresponding 
to its alphabetical position and adding these values we form 
a word value. For example, the word value for SKY is 19 + 11 
+ 25 = 55 = t_(10). If the word value is a triangle number 
then we shall call the word a triangle word.

Using words.txt (right click and 'Save Link/Target As...'), a 
16K text file containing nearly two-thousand common 
English words, how many are triangle words?
"""

triNums  = [0]
triWords = []

words = open('words.txt').read().split(',')
for x in range(len(words)):
    words[x] = words[x].strip('"')

maxVal = 0
for word in words:
    sum = 0
    for letter in word:
        sum += ord(letter)-64
    if sum > maxVal:
        maxVal = sum

n = 1
while max(triNums) <= maxVal:
    triNums.append(int(0.5*n*(n+1)))
    n+=1

for word in words:
    sum = 0
    for letter in word:
        sum += ord(letter)-64
    if sum in triNums:
        triWords.append(word)

print('There are',len(triWords),'triangle words in the list.')
