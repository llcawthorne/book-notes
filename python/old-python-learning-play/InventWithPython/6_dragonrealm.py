#!/usr/bin/env python3
# Dragon Realm
import random
import time

def playGame(prompt = 'Do you want to play again? (yes or no) '):
    print(prompt, end='')
    play = input()
    play = play.rstrip().lower()
    if play == 'y': play = 'yes'
    return play

def displayIntro():
    print()
    print('You are in a land full of dragons. In front of you,')
    print('you see two caves. In one cave, the dragon is friendly')
    print('and will share his treasure with you. The other dragon')
    print('is greedy and hungry, and will eat you on sight.')
    print()

def getChoice():
    yourChoice = ''
    while yourChoice != '1' and yourChoice != '2':
        print('Which cave will you go into? (1 or 2) ', end='')
        yourChoice = input()
    return yourChoice

def enterCave(yourChoice):
    print('You approach the cave...')
    time.sleep(2)
    print('It is dark and spooky...')
    time.sleep(2)
    print('A large dragon jumps out in front of you! He opens his jaws and...')
    print()
    time.sleep(2)
    rightChoice = random.randint(1,2)
    if yourChoice == str(rightChoice):
        print('says "We gonna have a party like it\'s 1999!!!"')
        print('and gives you some treasure!')
        print()
    else:
        print('Gobbles you down in one bite!')
        print()
        
if __name__ == '__main__':

    play = playGame('Would you like to play a game? (yes or no) ')

    while play == 'yes':
        displayIntro()
        choice = getChoice()
        enterCave(choice)
        play = playGame()

    input()
