module Main where
-- This is all the Property tests of Spec.hs redone using only QuickCheck
-- added a few tests from QuickCheck tutorials

import Arithmetic
import Data.Char (toUpper)
import Data.List (isPrefixOf, isSuffixOf, sort)
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
main = do
  putStrLn "half" 
  quickCheck prop_half
  quickCheck prop_halfIdentity
  putStrLn "sort"
  quickCheck prop_SortedInOrder
  putStrLn "Collatz"
  quickCheck prop_Collatz
  putStrLn "addition" 
  quickCheck (\n -> even (n::Int) ==> odd (n+1))
  quickCheck prop_AssociativeAddition
  quickCheck prop_CommutativeAddition
  putStrLn "multiplication" 
  quickCheck prop_AssociativeMultiplication
  quickCheck prop_CommutativeMultiplication
  putStrLn "quot,rem and div,mod" 
  quickCheck prop_QuotRem
  quickCheck prop_DivMod
  putStrLn "^ - these two should fail" 
  quickCheck prop_AssociativeExponentiation
  quickCheck prop_CommutativeExponentiation
  putStrLn "sqrt" 
  quickCheck prop_Sqrt
  putStrLn "list" 
  quickCheck prop_Index
  quickCheck prop_Index2
  quickCheck prop_RevRev
  quickCheck prop_RevApp
  quickCheck prop_PrefixSuffix
  putStrLn "$"
  quickCheck prop_ApplicationForInts
  quickCheck prop_ApplicationForChar
  quickCheck prop_ApplicationForString
  putStrLn "foldr"
  quickCheck prop_ConsToAppend
  quickCheck prop_AppendToConcat
  putStrLn "length and take" 
  quickCheck prop_LengthOfTakeN
  putStrLn "read of show" 
  quickCheck prop_ReadShowIdentityInt
  quickCheck prop_ReadShowIdentityChar
  quickCheck prop_ReadShowIdentityString
  putStrLn "Idempotence" 
  quickCheck prop_IdempotentCapitalize
  quickCheck prop_IdempotentSort
  putStrLn "Fool" 
  quickCheck testFool
  putStrLn "fibs"
  quickCheck prop_Fibonacci

divisor :: Gen Double
divisor = arbitrary `suchThat` (/= 0)

halfIdentity = (*2) . half

prop_half :: Double -> Bool
prop_half x = half x * 2 == x

prop_halfIdentity :: Double -> Bool
prop_halfIdentity x = halfIdentity x == x

prop_SortedInOrder :: [Int] -> Bool
prop_SortedInOrder xs = listOrdered (sort xs) == True

collatz :: Integer -> Integer
collatz n | even n = n `div` 2
          | odd n  = 3*n + 1

prop_Collatz :: Positive Integer -> Bool
prop_Collatz (Positive 1) = True
prop_Collatz (Positive n) = prop_Collatz (Positive $ collatz n)

prop_AssociativeAddition :: Int -> Int -> Int -> Bool
prop_AssociativeAddition x y z = (x + y) + z == x + (y + z)

prop_CommutativeAddition :: Int -> Int -> Bool
prop_CommutativeAddition x y = x + y == y + x

prop_AssociativeMultiplication :: Int -> Int -> Int -> Bool
prop_AssociativeMultiplication x y z = (x * y) * z == x * (y * z)

prop_CommutativeMultiplication :: Int -> Int -> Bool
prop_CommutativeMultiplication x y = x * y == y * x

prop_QuotRem :: Int -> NonZero Int -> Bool
prop_QuotRem x (NonZero y) = (quot x y)*y + (rem x y) == x

prop_DivMod :: Int -> NonZero Int -> Bool
prop_DivMod x (NonZero y) = (quot x y)*y + (rem x y) == x

prop_AssociativeExponentiation :: Positive Int -> Positive Int -> Positive Int -> Bool 
prop_AssociativeExponentiation (Positive x) (Positive y) (Positive z) =
  (x ^ y) ^ z == x ^ (y ^ z)

prop_CommutativeExponentiation :: Positive Int -> Positive Int -> Bool
prop_CommutativeExponentiation (Positive x) (Positive y) =
  x ^ y == y ^ x

prop_Sqrt :: Double -> Bool
prop_Sqrt x
  | x < 0            = isNaN (sqrt x)
  | x == 0 || x == 1 = sqrt x == x
  | x < 1            = sqrt x > x
  | x > 1            = sqrt x > 0 && sqrt x < x

prop_Index :: NonEmptyList Integer -> NonNegative Int -> Property
prop_Index (NonEmpty xs) (NonNegative n) =
  n < length xs ==> xs !! n == head (drop n xs)

prop_Index2 :: NonEmptyList Integer -> NonNegative Int -> Property
prop_Index2 (NonEmpty xs) (NonNegative n) =
  forAll (choose (0, length xs-1)) $ \n -> xs !! n == head (drop n xs)

prop_RevRev :: [Integer] -> Bool
prop_RevRev xs = reverse (reverse xs) == xs

prop_RevApp :: [Int] -> [Int] -> Bool
prop_RevApp xs ys = reverse (xs ++ ys) == reverse ys ++ reverse xs

prop_PrefixSuffix :: [Int] -> Int -> Bool
prop_PrefixSuffix xs n = isPrefixOf prefix xs &&
                         isSuffixOf (reverse prefix) (reverse xs)
  where prefix = take n xs

prop_ApplicationForInts :: Int -> Bool
prop_ApplicationForInts x = (numericFunction $ x) == numericFunction x

prop_ApplicationForChar :: Char -> Bool
prop_ApplicationForChar c = (toUpper $ c) == toUpper c

prop_ApplicationForString :: String -> Bool
prop_ApplicationForString s = (id $ s) == id s

numericFunction :: Int -> Int
numericFunction x = 2 * x + 5

prop_ConsToAppend :: [Int] -> [Int] -> Bool
prop_ConsToAppend xs ys = foldr (:) ys xs == xs ++ ys

prop_AppendToConcat :: [Int] -> [Int] -> [Int] -> Bool
prop_AppendToConcat xs ys zs = 
  foldr (++) [] [xs, ys, zs] == concat [xs, ys, zs]

prop_LengthOfTakeN :: Positive Int -> [Int] -> Property
prop_LengthOfTakeN (Positive n) xs =
  n < length xs ==> length (take n xs) == n

prop_ReadShowIdentityInt :: Int -> Bool
prop_ReadShowIdentityInt x = read (show x) == x

prop_ReadShowIdentityChar :: Char -> Bool
prop_ReadShowIdentityChar x = read (show x) == x

prop_ReadShowIdentityString :: String -> Bool
prop_ReadShowIdentityString x = read (show x) == x

twice f = f . f
fourTimes = twice . twice

capitalizeWord :: String -> String
capitalizeWord ""     = ""
capitalizeWord (x:xs) = toUpper x : xs

prop_IdempotentCapitalize :: String -> Bool
prop_IdempotentCapitalize x = capitalizeWord x == twice capitalizeWord x
                           && capitalizeWord x == fourTimes capitalizeWord x

prop_IdempotentSort :: [Int] -> Property
prop_IdempotentSort xs = classify (length xs < 2) "trivial" $
                         sort xs == twice sort xs
                      && sort xs == fourTimes sort xs

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

fibs :: [Int]
fibs = 0 : 1 : zipWith (+) fibs (tail fibs)

smallNonNegativeIntegers :: Gen Int
smallNonNegativeIntegers = choose (0, 500)

prop_Fibonacci :: Property
prop_Fibonacci =
  forAll smallNonNegativeIntegers $ \n ->
    let x = fibs !! (n)
        y = fibs !! (n+1)
        z = fibs !! (n+2)
    in x + y == z
