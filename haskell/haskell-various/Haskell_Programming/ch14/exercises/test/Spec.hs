module Main where

import Arithmetic
import Data.Char (toUpper)
import Data.List (sort)
import Test.Hspec
import Test.QuickCheck
import Test.QuickCheck.Modifiers (NonZero, Positive)
import WordNumber (digitToWord, digits, wordNumber)

listOrdered :: (Ord a) => [a] -> Bool 
listOrdered xs =
  snd $ foldr go (Nothing, True) xs 
  where go _ status@(_, False) = status 
        go y (Nothing, t) = (Just y, t)
        go y (Just x, t) = (Just y, x >= y)

main :: IO () 
main = hspec $ do
  describe "digitToWord" $ do
    it "returns zero for 0" $ do
      digitToWord 0 `shouldBe` "zero"
    it "returns one for 1" $ do
      digitToWord 1 `shouldBe` "one"
  describe "digits" $ do
    it "returns [1] for 1" $ do
      digits 1 `shouldBe` [1]
    it "returns [1, 0, 0] for 100" $ do
      digits 100 `shouldBe` [1, 0, 0]
  describe "wordNumber" $ do
    it "one-zero-zero given 100" $ do 
      wordNumber 100 `shouldBe` "one-zero-zero"
    it "nine-zero-zero-one for 9001" $ do
      wordNumber 9001 `shouldBe` "nine-zero-zero-one"
  describe "half" $ do
    it "(*2) . half should be identity" $ do
      property $ \x -> ((*2) . half) x == (x :: Double)
  describe "sort" $ do
    it "a sorted list should be in order" $ do
      property $ \l -> listOrdered (sort (l :: [Int])) == True
  describe "addition" $ do
    it "is an associative operation" $ do
      property $ \x y z -> (x::Int) + ((y::Int) + (z::Int)) == (x + y) + z
    it "is a commutative operation" $ do
      property $ \x y -> (x::Int) + (y::Int) == y + x
  describe "multiplication" $ do
    it "is an associative operation" $ do
      property $ \x y z -> (x::Int) * ((y::Int) * (z::Int)) == (x * y) * z
    it "is a commutative operation" $ do
      property $ \x y -> (x::Int) * (y::Int) == y * x
  describe "quot,rem and div,mod" $ do
    it "(quot x y)*y + (rem x y) == x" $ do
      property $ quotRemProp
    it "(div x y)*y + (mod x y) == x" $ do
      property $ divModProp 
  describe "^" $ do
    it "is it associative? NO.  This test will fail." $ do
      property $ associativeExponentiation
    it "is it commutative? NO.  This test will fail." $ do
      property $ commutativeExponentiation
  describe "list" $ do
    it "is itself when reversed twice" $ do
      property $ \l -> (reverse . reverse) (l::[Int]) == l
  describe "$" $ do
    it "is just function application for ints" $ do
      property $ \x -> (numericFunction $ x) == numericFunction x
    it "is just function application for char" $ do
      property $ \x -> (toUpper $ x) == toUpper x
    it "is just function application for strings" $ do
      property $ \x -> (id $ (x::String)) == id x
  describe "foldr" $ do
    it "can make (:) into (++)" $ do
      property $ \xs ys -> foldr (:) (ys::[Int]) (xs::[Int]) == xs ++ ys 
    it "can make (++) into concat" $ do
      property $ \xs ys zs ->
        foldr (++) [] [(xs::[Int]), (ys::[Int]), (zs::[Int])]
        == concat [xs, ys, zs]
  describe "length and take" $ do
    it "length of take n is n. FAILS on [] or shorter than n list" $ do
      property $ lengthOfTakeN
  describe "read of show" $ do
    it "should be identity for Int" $ do
      property $ \x -> (read (show (x::Int))) == x
    it "should be identity for Char" $ do
      property $ \x -> (read (show (x::Char))) == x
    it "should be identity for String" $ do
      property $ \x -> (read (show (x::String))) == x
  describe "Idempotence" $ do
    it "capitalizeWord is idempotent" $ do
      property $ \x -> (capitalizeWord (x::String) == twice capitalizeWord x)
                    && (capitalizeWord x           == fourTimes capitalizeWord x)
    it "sort is idempotent" $ do
      property $ \x -> (sort (x::[Int]) == twice sort x)
                    && (sort x          == fourTimes sort x)
  describe "Fool" $ do
    it "all Fool's are equal" $ do
      property $ testFool

quotRemProp :: Int -> NonZero Int -> Bool
quotRemProp x (NonZero y) = (quot x y)*y + (rem x y) == x

divModProp :: Int -> NonZero Int -> Bool
divModProp x (NonZero y) = (quot x y)*y + (rem x y) == x

associativeExponentiation :: Positive Int -> Positive Int -> Positive Int -> Bool 
associativeExponentiation (Positive x) (Positive y) (Positive z) =
  (x ^ y) ^ z == x ^ (y ^ z)

commutativeExponentiation :: Positive Int -> Positive Int -> Bool
commutativeExponentiation (Positive x) (Positive y) =
  x ^ y == y ^ x

numericFunction :: Int -> Int
numericFunction x = 2 * x + 5

lengthOfTakeN :: Positive Int -> [Int] -> Bool
lengthOfTakeN (Positive n) xs = length (take n xs) == n

twice f = f . f
fourTimes = twice . twice

capitalizeWord :: String -> String
capitalizeWord ""     = ""
capitalizeWord (x:xs) = toUpper x : xs

data Fool =
    Fulse
  | Frue
  deriving (Eq, Show)

instance Arbitrary Fool where
  arbitrary = weightedFoolGen

foolGen :: Gen Fool
foolGen = elements [Fulse, Frue]

weightedFoolGen :: Gen Fool
weightedFoolGen = frequency [ (2, return Fulse)
                            , (1, return Frue) ]

testFool :: Fool -> Fool -> Bool
testFool _ _ = True
