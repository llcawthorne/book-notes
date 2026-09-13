-- src/Semigroup.hs
module Semigroup where

import Data.Semigroup
import Data.Monoid
import Test.QuickCheck

-- Trivial
data Trivial = Trivial deriving (Eq, Show)

instance Semigroup Trivial where
  _ <> _ = Trivial

instance Arbitrary Trivial where
  arbitrary = return Trivial

-- general law for semigroups
semigroupAssoc :: (Eq m, Semigroup m) => m -> m -> m -> Bool
semigroupAssoc a b c = (a <> (b <> c)) == ((a <> b) <> c)

type TrivAssoc = 
  Trivial -> Trivial -> Trivial -> Bool

testTrivAssoc :: IO ()
testTrivAssoc = quickCheck (semigroupAssoc :: TrivAssoc)

-- Identity
data Identity a = Identity a deriving (Eq, Show)

instance Semigroup a => Semigroup (Identity a) where
  (Identity a) <> (Identity b) = Identity $ a <> b

instance Arbitrary a => Arbitrary (Identity a) where
  arbitrary = do
    v <- arbitrary
    return (Identity v)

type IdentAssoc a = Identity a -> Identity a -> Identity a -> Bool

testIdentAssoc :: IO ()
testIdentAssoc = quickCheck (semigroupAssoc :: IdentAssoc String)

-- Two
data Two a b = Two a b
  deriving (Eq, Show)

instance (Semigroup a, Semigroup b) => Semigroup (Two a b) where
  (Two a b) <> (Two a' b') = Two (a <> a') (b <> b')

instance (Arbitrary a, Arbitrary b) => Arbitrary (Two a b) where
  arbitrary = do
    a <- arbitrary
    b <- arbitrary
    return (Two a b)

type TwoAssoc a b = Two a b -> Two a b -> Two a b -> Bool

testTwoAssoc :: IO ()
testTwoAssoc = quickCheck (semigroupAssoc :: TwoAssoc String String)

-- Three
data Three a b c = Three a b c
  deriving (Eq, Show)

instance (Semigroup a, Semigroup b, Semigroup c) => 
          Semigroup (Three a b c) where
  (Three a b c) <> (Three a' b' c') = Three (a <> a') (b <> b') (c <> c')

instance (Arbitrary a, Arbitrary b, Arbitrary c) => 
          Arbitrary (Three a b c) where
  arbitrary = do
    a <- arbitrary
    b <- arbitrary
    c <- arbitrary
    return (Three a b c)

type ThreeAssoc a b c = Three a b c -> Three a b c -> Three a b c -> Bool

testThreeAssoc :: IO ()
testThreeAssoc = quickCheck (semigroupAssoc :: ThreeAssoc String String String)

-- Four
data Four a b c d = Four a b c d
  deriving (Eq, Show)

instance (Semigroup a, Semigroup b, Semigroup c, Semigroup d) =>
          Semigroup (Four a b c d) where
  (Four a b c d) <> (Four a' b' c' d') =
    Four (a <> a') (b <> b') (c <> c') (d <> d')

instance (Arbitrary a, Arbitrary b, Arbitrary c, Arbitrary d) => 
          Arbitrary (Four a b c d) where
  arbitrary = do
    a <- arbitrary
    b <- arbitrary
    c <- arbitrary
    d <- arbitrary
    return (Four a b c d)

type FourAssoc a b c d = 
  Four a b c d -> Four a b c d -> Four a b c d -> Bool

testFourAssoc :: IO ()
testFourAssoc = 
  quickCheck (semigroupAssoc :: FourAssoc String String String String)

-- BoolConj
newtype BoolConj = BoolConj Bool
  deriving (Eq, Show)

instance Semigroup BoolConj where
  (BoolConj x) <> (BoolConj y) = BoolConj (x && y)

instance Arbitrary BoolConj where
  arbitrary = do
    a <- arbitrary
    return (BoolConj a)

type BoolConjAssoc = BoolConj -> BoolConj -> BoolConj -> Bool

testBoolConjAssoc :: IO ()
testBoolConjAssoc = quickCheck (semigroupAssoc :: BoolConjAssoc)

-- BoolDisj
newtype BoolDisj = BoolDisj Bool
  deriving (Eq, Show)

instance Semigroup BoolDisj where
  (BoolDisj x) <> (BoolDisj y) = BoolDisj (x || y)
  
instance Arbitrary BoolDisj where
  arbitrary = do
    a <- arbitrary
    return (BoolDisj a)

type BoolDisjAssoc = BoolDisj -> BoolDisj -> BoolDisj -> Bool

testBoolDisjAssoc :: IO ()
testBoolDisjAssoc = quickCheck (semigroupAssoc :: BoolDisjAssoc)

-- Or a b
data Or a b = Fst a | Snd b
  deriving (Eq, Show)

instance Semigroup (Or a b) where
  (Fst _) <> b = b
  (Snd a) <> (Fst _) = Snd a
  (Snd _) <> (Snd b) = Snd b

instance (Arbitrary a, Arbitrary b) => Arbitrary (Or a b) where
  arbitrary = do
    a <- arbitrary
    b <- arbitrary
    elements [Fst a, Snd b]

type OrAssoc a b = Or a b -> Or a b -> Or a b -> Bool

testOrAssoc :: IO ()
testOrAssoc = quickCheck (semigroupAssoc :: OrAssoc Int Int)

-- Combine a b
plusOne :: Combine Int (Sum Int)
plusOne = Combine $ \n -> Sum (n + 1)
minusOne :: Combine Int (Sum Int)
minusOne = Combine $ \n -> Sum (n - 1)

newtype Combine a b =
  Combine { unCombine :: (a -> b) }

instance Show (Combine a b) where
  show _ = "Combine <function>"

instance Semigroup b => Semigroup (Combine a b) where
  (Combine f) <> (Combine g) = Combine $ (\a -> (f a) <> (g a))

instance (CoArbitrary a, Arbitrary b) => Arbitrary (Combine a b) where
  arbitrary = do
    f <- arbitrary
    return (Combine f)

type CombineAssocType = String -> Combine String String -> Combine String String
                     -> Combine String String -> Bool

combineAssoc :: (Eq b, Semigroup b) => 
                 a -> Combine a b -> Combine a b -> Combine a b -> Bool
combineAssoc x f g h =
  unCombine (f <> (g <> h)) x == unCombine ((f <> g) <> h) x

testCombineAssoc :: IO ()
testCombineAssoc = quickCheck (combineAssoc :: CombineAssocType)
-- testCombineAssoc :: IO ()
-- testCombineAssoc = quickCheck (semigroupAssoc :: CombineAssoc String String)

-- Comp a
newtype Comp a = Comp { unComp :: (a -> a) }

instance Show (Comp a) where
  show _ = "Comp <function>"

instance Semigroup (Comp a) where
  (Comp f) <> (Comp g) = Comp $ f . g

instance (CoArbitrary a, Arbitrary a) => Arbitrary (Comp a)  where
  arbitrary = do
    f <- arbitrary
    return (Comp f)

type CompAssocType = String -> Comp String -> Comp String  -> Comp String -> Bool

compAssoc :: (Eq a) => a -> Comp a -> Comp a -> Comp a -> Bool
compAssoc x f g h =
  unComp (f <> (g <> h)) x == unComp ((f <> g) <> h) x

testCompAssoc :: IO ()
testCompAssoc = quickCheck (compAssoc :: CompAssocType)
-- testCombineAssoc :: IO ()
-- testCombineAssoc = quickCheck (semigroupAssoc :: CombineAssoc String String)

-- Validation a b
data Validation a b = Fail a | Succ b
  deriving (Eq, Show)

instance Semigroup a => Semigroup (Validation a b) where
  (Succ a) <> b = Succ a
  (Fail _) <> (Succ b) = Succ b
  (Fail a) <> (Fail b) = Fail (a <> b)

instance (Arbitrary a, Arbitrary b) => Arbitrary (Validation a b) where
  arbitrary = do
    a <- arbitrary
    b <- arbitrary
    elements [Fail a, Succ b]

type ValidationAssoc a b = Validation a b -> Validation a b -> 
                           Validation a b -> Bool

testValidationAssoc :: IO ()
testValidationAssoc = quickCheck (semigroupAssoc :: ValidationAssoc String Int)
