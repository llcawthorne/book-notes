module Spec where
-- I tried setting this to Main to make it work with stack test
-- but that broke my import of Main, thinking it was cyclic

import Main (Puzzle(..), fillInCharacter, freshPuzzle, handleGuess)
import Test.Hspec
import Test.QuickCheck

main :: IO ()
main = hspec $ do
  describe "fillInCharacter" $ do
    it "adds item to guessed to guessed chars" $ do
      fillInCharacter aFreshPuzzle 'q' `shouldBe` aFreshPuzzleWithQ
      fillInCharacter aMissedGuessesPuzzle 'q' `shouldBe` aMissedGuessesPuzzleWithQ
      fillInCharacter aMissedGuessesPuzzle 'p' `shouldBe` aMissedGuessesPuzzleWithP
    it "fills in the word for a match" $ do
      fillInCharacter aFreshPuzzle 'l' `shouldBe` aFreshPuzzleWithL
      fillInCharacter aMissedGuessesPuzzle 'p' `shouldBe` aMissedGuessesPuzzleWithP
      fillInCharacter aPartialPuzzle 'o' `shouldBe` aPartialPuzzleWithO
    it "returns same filled in word for a miss" $ do
      fillInCharacter aFreshPuzzle 'q' `shouldBe` aFreshPuzzleWithQ
      fillInCharacter aMissedGuessesPuzzle 'q' `shouldBe` aMissedGuessesPuzzleWithQ
      fillInCharacter aPartialPuzzle 'q' `shouldBe` aPartialPuzzleWithQ
  -- describe "handleGuess" $ do
  --  it "returns the same puzzle for an already picked character" $ do
  --    id 0 `shouldBe` 0
  -- I couldn't figure out thow to test handleGuess, because it returns
  -- a Puzzle wrapped in IO.  Maybe come back to this after IO chapter...

aFreshPuzzle :: Puzzle
aFreshPuzzle = freshPuzzle "leopold"

aFreshPuzzleWithQ :: Puzzle
aFreshPuzzleWithQ = Puzzle "leopold"
                           (map (const Nothing) "leopold")
                           ['q']

aFreshPuzzleWithL :: Puzzle
aFreshPuzzleWithL = Puzzle "leopold"
                           [Just 'l', Nothing, Nothing, Nothing, Nothing, Just 'l', Nothing]
                           ['l']

aMissedGuessesPuzzle :: Puzzle
aMissedGuessesPuzzle = Puzzle "patricia" 
                              (map (const Nothing) "patricia") 
                              ['b', 'd', 'm', 'n', 'z']

aMissedGuessesPuzzleWithQ :: Puzzle
aMissedGuessesPuzzleWithQ = Puzzle "patricia" 
                              (map (const Nothing) "patricia") 
                              ['q', 'b', 'd', 'm', 'n', 'z']

aMissedGuessesPuzzleWithP :: Puzzle
aMissedGuessesPuzzleWithP = Puzzle "patricia" 
                              [Just 'p', Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing]
                              ['p', 'b', 'd', 'm', 'n', 'z']

aPartialPuzzle :: Puzzle
aPartialPuzzle = Puzzle "arnoldo"
                        [Just 'a', Nothing, Just 'n', Nothing, Nothing, Nothing, Nothing]
                        ['a', 'n', 'z']

aPartialPuzzleWithQ :: Puzzle
aPartialPuzzleWithQ = Puzzle "arnoldo"
                        [Just 'a', Nothing, Just 'n', Nothing, Nothing, Nothing, Nothing]
                        ['q', 'a', 'n', 'z']

aPartialPuzzleWithO :: Puzzle
aPartialPuzzleWithO = Puzzle "arnoldo"
                        [Just 'a', Nothing, Just 'n', Just 'o', Nothing, Nothing, Just 'o']
                        ['o', 'a', 'n', 'z']
