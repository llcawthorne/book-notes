#!/usr/bin/env python3
# Random number guessing game
import random
maxNum = 10

numGuess = 1
myNumber = random.randint(1,maxNum)
while numGuess < 6:
    print('Pick a number 1 to', maxNum, ':',end=' ')
    myInput = input()
    if myInput == "q": numGuess=0; break
    try:
        myGuess = int(myInput)
    except:
        continue
    if myGuess != myNumber:
        myHint = 'Guess lower' if myGuess > myNumber else 'Guess higher'
        print(myHint,'when you guess again!')
        numGuess += 1
    else:
        print('You win a taco!')
        break
else:
    print('I pitty da fool that did not guess', myNumber)

if numGuess > 0 and numGuess < 6:
    print('You guessed',myGuess,'after',numGuess,'guesses.')
    print('Enjoy your taco!')

input()
