-- Addition.hs
module Addition where

import Data.List (sort)
import Test.Hspec
import Test.QuickCheck

sayHello :: IO ()
sayHello = putStrLn("Hello!")

main :: IO ()
main = hspec $ do
  describe "Addition" $ do
    it "calculates 1 + 1 is greater than 1" $ do
      (1 + 1) > (1 :: Int) `shouldBe` True
    it "calculates 2 + 2 is equal to 4" $ do
      2 + 2 `shouldBe` (4 :: Int)
    -- Note: asserting the type of x is necessary to generate x.
    -- Note: this could fail if it tested (maxBound :: Int)
    it "calculates x + 1 is always\
        \ greater than x" $ do
      property $ \x -> x + 1 > (x :: Int)
    it "is associative" $ do
      property $ \(x :: Int) y z -> x + (y + z) == (x + y) + z
    it "is commutative" $ do
      property $ \(x :: Int) y -> x + y == y + x


  describe "Multiplication" $ do
    it "calculates 5 times 10 is 50" $ do
      multiplyBy 5 10 `shouldBe` (50 :: Int)
    it "is associative with multiplyBy" $ do
      property $ 
        forAll (choose (0, 100)) $ \(x :: Int) ->
          forAll (choose (0, 100)) $ \y ->
            forAll (choose (0, 100)) $ \z ->
              multiplyBy x (multiplyBy y z) == multiplyBy (multiplyBy x y) z
    it "is commutative with multiplyBy" $ do
      property $ 
        forAll (choose (0, 100)) $ \(x :: Int) ->
          forAll (choose (0, 100)) $ \y ->
            multiplyBy x y == multiplyBy y x
    -- my implementation is too inefficient for random values
    it "is associative" $ do
      property $ \(x :: Int) y z -> x * (y * z) == (x * y) * z
    it "is commutative" $ do
      property $ \(x :: Int) y -> x * y == y * x

  describe "Division" $ do
    it "calculates 15 divided by 3 is 5" $ do
      dividedBy 15 3 `shouldBe` ((5, 0) :: (Int, Int))
    it "calculates 22 divided by 5 is\
        \ 4 remainder 2" $ do
      dividedBy 22 5 `shouldBe` ((4, 2) :: (Int, Int))
    -- again, we'll use QuickCheck with native definitions
    it "preserves the relationship between quot and rem" $ do
      property $ \(x :: Int) y -> y /= 0 ==> (quot x y) * y + (rem x y) == x
    it "preserves the relationship between div and mod" $ do
      property $ \(x :: Int) y -> y /= 0 ==> (div x y) * y + (mod x y) == x

  describe "Exponentiation" $ do
    it "is not associative" $ do
      expectFailure $ 
        forAll (choose (1, 100)) $ \(x :: Int) ->
          forAll (choose (1, 100)) $ \(y :: Int) ->
            forAll (choose (1, 100)) $ \(z :: Int) ->
              x ^ (y ^ z) == (x ^ y) ^ z
    it "is not commutative" $ do
      expectFailure $ 
        \(x :: Int) ->
          forAll (choose (1, 100)) $ \(y :: Int) ->
            x ^ y == y ^ x

  describe "List reversal" $ do
    it "is id if done twice on Ints" $ do
      property $ \(xs :: [Int]) -> (reverse . reverse) xs == id xs
    it "is id if done twice on String" $ do
      property $ \(xs :: [String]) -> (reverse . reverse) xs == id xs
      

dividedBy :: Integral a => a -> a -> (a, a)
dividedBy num denom = go num denom 0
  where go n   d count
         | n < d = (count, n)
         | otherwise =
             go (n - d) d (count + 1)

multiplyBy :: Integral a => a -> a -> a
multiplyBy x y = go x y 0
  where go _ 0 z' = z'
        go x' y' z' = go x' (y' - 1) (z' + x')

-- Using QuickCheck without hspec
-- Note: this could fail if it tested (maxBound :: Int)
prop_additionGreater :: Int -> Bool
prop_additionGreater x = x + 1 > x

prop_plusAssociative :: Int -> Int -> Int -> Bool
prop_plusAssociative x y z = x + (y + z) == (x + y) + z

prop_plusCommutative :: Int -> Int -> Bool
prop_plusCommutative x y = x + y == y + x

prop_multAssociative :: Int -> Int -> Int -> Bool
prop_multAssociative x y z = x * (y * z) == (x * y) * z

prop_multCommutative :: Int -> Int -> Bool
prop_multCommutative x y = x * y == y * x

prop_divQuotRem :: Int -> Int -> Property
prop_divQuotRem x y = y /= 0 ==> (quot x y) * y + (rem x y) == x

prop_divDivMod :: Int -> Int -> Property
prop_divDivMod x y = y /= 0 ==> (div x y) * y + (mod x y) == x

-- Testing a polymorphic property with minimal restrictions.
-- We still have to make it concrete at the test site.
prop_reverseReverse :: (Eq a, Show a, Arbitrary a) => [a] -> Bool
prop_reverseReverse xs = (reverse . reverse) xs == xs

prop_dollarIsApplication :: Int -> Bool
prop_dollarIsApplication x = negate x == (negate $ x)

prop_takeLength :: Int -> [Int] -> Property
prop_takeLength n xs = expectFailure $ length (take n xs) == n

prop_takeLengthTrue :: Int -> [Int] -> Bool
prop_takeLengthTrue n xs = length (take n xs) == min (max n 0) (length xs)

prop_readShow :: Int -> Bool
prop_readShow x = (read (show x)) == x

prop_squareSqrt :: Float -> Property
prop_squareSqrt x = expectFailure $ (square . sqrt) x == x

prop_squareSqrtEpsilon :: Float -> Property
prop_squareSqrtEpsilon x = x > 0 ==> abs (((square . sqrt) x) - x) < epsilon

square :: Float -> Float
square x = x * x

epsilon :: Float
epsilon = 0.001

prop_idempotentAbs :: Int -> Bool
prop_idempotentAbs x = f x == f (f x) && f (f x) == f (f (f x))
  where f = abs

prop_idempotentSort :: [Int] -> Bool
prop_idempotentSort xs = f xs == f (f xs) && f (f xs) == f (f (f xs))
  where f = sort

runQc :: IO ()
runQc = do
  quickCheck prop_additionGreater
  quickCheck prop_plusAssociative 
  quickCheck prop_plusCommutative
  quickCheck prop_multAssociative
  quickCheck prop_multCommutative
  quickCheck prop_divQuotRem
  quickCheck prop_divDivMod
  quickCheck (prop_reverseReverse :: [Int] -> Bool)
  quickCheck (prop_reverseReverse :: [String] -> Bool)
  quickCheck prop_dollarIsApplication
  quickCheck prop_takeLength
  quickCheck prop_takeLengthTrue
  quickCheck prop_readShow
  quickCheck prop_squareSqrt
  quickCheck prop_squareSqrtEpsilon
  quickCheck prop_idempotentAbs
  quickCheck prop_idempotentSort
