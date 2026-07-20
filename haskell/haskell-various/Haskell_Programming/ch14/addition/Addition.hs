module Addition where

import Test.Hspec
import Test.QuickCheck

mult :: (Eq a, Num a) => a -> a -> a
mult _ 0 = 0
mult n 1 = n
mult n x = n + mult n (x-1)

dividedBy :: Integral a => a -> a -> (a, a)
dividedBy num denom = go num denom 0
  where go n   d count
         | n < d = (count, n)
         | otherwise =
             go (n -d) d (count + 1)

main :: IO ()
main = hspec $ do
  describe "Addition" $ do
    it "1 + 1 is greater than 1" $ do
      ((1 :: Integer) + (1 :: Integer)) > 1 `shouldBe` True
    it "2 + 2 is equal to 4" $ do
      ((2 :: Integer) + (2 :: Integer)) `shouldBe` 4
    it "x + 1 is always greater than x" $ do
      property $ \x -> x + 1 > (x :: Int)
  describe "mult" $ do
    it "5 times 3 is 15" $ do
      mult (5::Integer) (3::Integer) `shouldBe` 15
    it "7 times 5 is 35" $ do
      mult (7::Integer) (5::Integer) `shouldBe` 35
  describe "dividedBy" $ do
    it "15 divided by 3 is 5" $ do
      dividedBy (15::Integer) (3::Integer) `shouldBe` (5, 0)
    it "22 divided by 5 is 4 remainder 2" $ do
      dividedBy (22::Integer) (5::Integer) `shouldBe` (4, 2)

-- Various QuickCheck generators
oneThroughThree :: Gen Int
oneThroughThree = elements [1, 2, 3]

genBool :: Gen Bool
genBool = choose (False, True)

genBool' :: Gen Bool
genBool' = elements [False, True]

genOrdering :: Gen Ordering
genOrdering = elements [LT, EQ, GT]

genChar :: Gen Char
genChar = elements ['a'..'z']

-- you can use genTuple like "sample (genTuple :: Gen (Int, Float))"
genTuple :: (Arbitrary a, Arbitrary b) => Gen (a, b)
genTuple = do
  a <- arbitrary
  b <- arbitrary
  return (a, b)

genThreeple :: (Arbitrary a, Arbitrary b, Arbitrary c)
            => Gen (a, b, c)
genThreeple = do
  a <- arbitrary
  b <- arbitrary 
  c <- arbitrary
  return (a, b, c)

genEither :: (Arbitrary a, Arbitrary b) => Gen (Either a b)
genEither = do
  a <- arbitrary
  b <- arbitrary
  elements [Left a, Right b]

-- try "sample (genMaybe :: Gen (Maybe Int))"
genMaybe :: Arbitrary a => Gen (Maybe a)
genMaybe = do
  a <- arbitrary
  frequency [ (1, return Nothing)
            , (3, return (Just a))]

-- QuickCheck works without hspec
prop_additionGreater :: Int -> Bool
prop_additionGreater x = x + 1 > x

runQc :: IO ()
runQc = quickCheck prop_additionGreater
