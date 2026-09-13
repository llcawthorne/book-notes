module Main where

import Data.List (nub)
import Hangman (fillInCharacter, gameWords, handleGuess, Puzzle(..), WordList(..))
import System.IO.Unsafe (unsafePerformIO)
import Test.Hspec
import Test.QuickCheck

-- Really for testing, a fixed list of words would have been sufficient
-- but I've never done this before.
gameWordsOutput :: WordList
gameWordsOutput = unsafePerformIO gameWords

genPuzzleString :: WordList -> Gen String
genPuzzleString (WordList wordList) = elements wordList

genPartiallySolved :: String -> [Char] -> Gen [Maybe Char]
genPartiallySolved str guessed = do
  let s = [ if ch `elem` guessed then Just ch else Nothing | ch <- str]
  return s

genGuessedLetters :: Gen [Char]
genGuessedLetters = do
  n <- choose(0, 6)
  ltrs <- vectorOf n $ elements ['a'..'z']
  return (nub ltrs)

genPuzzle :: Gen Puzzle
genPuzzle = do
  str     <- genPuzzleString gameWordsOutput
  guessed <- genGuessedLetters
  solved  <- genPartiallySolved str guessed
  return $ Puzzle str solved guessed

instance Arbitrary Puzzle where
  arbitrary = genPuzzle

main :: IO ()
main = hspec $ do
  describe "fillInCharacter" $ do
    it "should fill in a character for a character in the word" $ do
      fillInCharacter (Puzzle "dog" [Nothing, Nothing, Nothing] []) 'd'
        `shouldBe`
        Puzzle "dog" [Just 'd', Nothing, Nothing] ['d']
    it "should not fill in a character for a character not in the word" $ do
      fillInCharacter (Puzzle "dog" [Nothing, Nothing, Nothing] []) 'e' 
        `shouldBe`
        Puzzle "dog" [Nothing, Nothing, Nothing] ['e']
    it "should handle repeated guesses that it will never be passed" $ do
      fillInCharacter (Puzzle "dog" [Just 'd', Nothing, Nothing] ['d']) 'd' 
        `shouldBe`
        Puzzle "dog" [Just 'd', Nothing, Nothing] ['d', 'd']
    it "should fill in multiple characters" $ do
      fillInCharacter (Puzzle "moon" [Nothing, Nothing, Nothing, Nothing] []) 'o'
        `shouldBe`
        Puzzle "moon" [Nothing, Just 'o', Just 'o', Nothing] ['o']
    it "shouldn't hide a revealed character after an incorrect guess" $ do
      fillInCharacter (Puzzle "moon" [Nothing, Just 'o', Just 'o', Nothing] ['o']) 'd'
        `shouldBe`
        Puzzle "moon" [Nothing, Just 'o', Just 'o', Nothing] ['d', 'o']
    it "shouldn't hide a revealed character after a correct guess" $ do
      fillInCharacter (Puzzle "moon" [Nothing, Just 'o', Just 'o', Nothing] ['o']) 'm'
        `shouldBe`
         Puzzle "moon" [Just 'm', Just 'o', Just 'o', Nothing] ['m', 'o']
    -- only doing property tests for this one since it isn't IO
    it "reveals every occurrence of a guessed letter" $
      property $
        forAll (genPuzzleString gameWordsOutput) $ \word ->
        forAll (elements word) $ \guess ->
          let puzzle = Puzzle word (replicate (length word) Nothing) []
              Puzzle _ solved _ = fillInCharacter puzzle guess
              expectedPositions = [i | (i, c) <- zip [0..] word, c == guess]
              actualPositions   = [i | (i, mc) <- zip [0..] solved, mc == Just guess]
           in expectedPositions == actualPositions
    it "never hides an already-revealed letter" $
      property $ \puzzle guess ->
        let Puzzle _ before _ = puzzle
            Puzzle _ after  _ = fillInCharacter puzzle guess
            stillRevealed (Just c) (Just c') = c == c'
            stillRevealed (Just _) Nothing   = False
            stillRevealed Nothing  _         = True
         in and (zipWith stillRevealed before after)
  describe "handleGuess" $ do
    it "should handle a correct guess" $ do
      result <- handleGuess (Puzzle "dog" [Nothing, Nothing, Nothing] []) 'd'
      result `shouldBe` Puzzle "dog" [Just 'd', Nothing, Nothing] ['d']
    it "should handle a wrong guess" $ do
      result <- handleGuess (Puzzle "dog" [Nothing, Nothing, Nothing] []) 'e'
      result `shouldBe` Puzzle "dog" [Nothing, Nothing, Nothing] ['e']
    it "should handle a repeated guess" $ do
      result <- handleGuess (Puzzle "dog" [Just 'd', Nothing, Nothing] ['d']) 'd'
      result `shouldBe` Puzzle "dog" [Just 'd', Nothing, Nothing] ['d']
    it "should fill in multiple characters" $ do
      result <- handleGuess 
          (Puzzle "moon" [Nothing, Nothing, Nothing, Nothing] []) 'o'
      result `shouldBe` Puzzle "moon" [Nothing, Just 'o', Just 'o', Nothing] ['o']
    it "shouldn't hide a revealed character after an incorrect guess" $ do
      result <- 
        handleGuess 
          (Puzzle "moon" [Nothing, Just 'o', Just 'o', Nothing] ['o']) 'd'
      result `shouldBe`
        Puzzle "moon" [Nothing, Just 'o', Just 'o', Nothing] ['d', 'o']
    it "shouldn't hide a revealed character after a correct guess" $ do
      result <- 
        handleGuess 
          (Puzzle "moon" [Nothing, Just 'o', Just 'o', Nothing] ['o']) 'm'
      result `shouldBe` 
        Puzzle "moon" [Just 'm', Just 'o', Just 'o', Nothing] ['m', 'o']
