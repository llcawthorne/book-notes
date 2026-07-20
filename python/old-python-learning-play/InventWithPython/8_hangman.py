#!/usr/bin/env python3
# Hangman!
import random
HANGMANPICS = ['''

   +---+
   |   |
       |
       |
       |
       |
 =========''', '''

   +---+
   |   |
   O   |
       |
       |
       |
 =========''', '''

   +---+
   |   |
   O   |
   |   |
       |
       |
 =========''', '''

   +---+
   |   |
   O   |
  /|   |
       |
       |
 =========''', '''

   +---+
   |   |
   O   |
  /|\  |
       |
       |
 =========''', '''

   +---+
   |   |
   O   |
  /|\  |
  /    |
       |
 =========''', '''

   +---+
   |   |
   O   |
  /|\  |
  / \  |
       |
 =========''']
words = 'ant baboon badger bat bear beaver camel cat clam cobra cougar coyote crow deer dog donkey duck eagle ferret fox frog goat goose hawk lion lizard llama mole monkey moose mouse mule newt otter owl panda parrot pigeon python rabbit ram rat raven rhino salmon seal shark sheep skunk sloth snake spider stork swan tiger toad trout turkey turtle weasel whale wolf wombat zebra'.split()
failures = 0
secretWord = ''
myGuess = []
guessed = []
epicFail = False
playing = True

def initialize_game():
    global failures, secretWord, myGuess
    failures = 0
    secretWord = random.choice(words)
    for letter in secretWord:
        myGuess.append('_')
    
def display(guess, fail):
    print(HANGMANPICS[fail])
    print(' ',end='')
    for letter in guess:
        print(letter, end=' ')
    print()

def getGuess():
    global guessed
    newLetter = ''
    while not newLetter.isalpha():
        print('What do you think? ',end='')
        newLetter = input()
        if newLetter in guessed:
            print('Sorry, you\'ve tried',newLetter,'already.')
            newLetter = ''
        else:
            guessed.append(newLetter)
    return newLetter

if __name__ == '__main__':
    while playing:
        initialize_game()
        while failures < len(HANGMANPICS)-1 and '_' in myGuess:
            display(myGuess, failures)
            print(' Letters used: ',guessed)
            attempt = getGuess()
            if attempt in secretWord:
                print(" Good showing. ",attempt,'up in da hiz-ouse.')
                for x in range(len(secretWord)):
                    if secretWord[x] == attempt:
                        myGuess[x] = attempt
            else:
                print(" Sorry old chap.  Not a",attempt,"to be found.")
                failures += 1
        else:
            display(myGuess, failures)
            if '_' in myGuess:
                print(" You just lost The Game!")
                print()
            else:
                print(" YAYAYAYAY!")
                print(' we do not have any cake')
                print()
        print(' Test fate again, matey? ',end='')
        pmore = input()
        if pmore.lower()[0] != 'y': playing=False
    else:
        print(" Thank you for playing The Game! ")
        input()
