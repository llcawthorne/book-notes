-- src/Monoid.hs
module Monoid where

import Data.Semigroup
import Data.Monoid
import Test.QuickCheck

-- Trivial
data Trivial = Trivial deriving (Eq, Show)

instance Semigroup Trivial where
  _ <> _ = Trivial

instance Monoid Trivial where
  mempty = undefined
  mappend = (<>)

instance Arbitrary Trivial where
  arbitrary = return Trivial

-- general law for semigroups
semigroupAssoc :: (Eq m, Semigroup m) => m -> m -> m -> Bool
semigroupAssoc a b c = (a <> (b <> c)) == ((a <> b) <> c)

monoidLeftIdentity :: (Eq m, Monoid m) => m -> Bool
monoidLeftIdentity a = (mempty <> a) == a

monoidRightIdentity :: (Eq m, Monoid m) => m -> Bool
monoidRightIdentity a = (a <> mempty) == a

sa :: (Eq m, Semigroup m) => m -> m -> m -> Bool
sa = semigroupAssoc
mli :: (Eq m, Monoid m) => m -> Bool
mli = monoidLeftIdentity 
mlr :: (Eq m, Monoid m) => m -> Bool
mlr = monoidRightIdentity 

type TrivAssoc = 
  Trivial -> Trivial -> Trivial -> Bool

type TrivIdent = Trivial -> Bool

testTrivMonoid :: IO ()
testTrivMonoid = do
  quickCheck (sa :: TrivAssoc)
  quickCheck (mli :: TrivIdent)
  quickCheck (mlr :: TrivIdent)

-- Identity a
data Identity a = Identity a deriving (Eq, Show)

instance Semigroup a => Semigroup (Identity a) where
  Identity a <> Identity b = Identity (a <> b)

instance Monoid a => Monoid (Identity a) where
  mempty = Identity mempty
  mappend = (<>)

instance Arbitrary a => Arbitrary (Identity a) where
  arbitrary = do
    a <- arbitrary
    return (Identity a)

type IdentAssoc a = Identity a -> Identity a -> Identity a -> Bool

type IdentIdent a = Identity a -> Bool

testIdentMonoid :: IO ()
testIdentMonoid = do
  quickCheck (sa :: IdentAssoc String)
  quickCheck (mli :: IdentIdent String)
  quickCheck (mlr :: IdentIdent String)

-- Two a b
data Two a b = Two a b deriving (Eq, Show)

instance (Semigroup a, Semigroup b) => Semigroup (Two a b) where
  Two a b <> Two a' b' = Two (a <> a') (b <> b')

instance (Monoid a, Monoid b) => Monoid (Two a b) where
  mempty = Two mempty mempty
  mappend = (<>)

instance (Arbitrary a, Arbitrary b) => Arbitrary (Two a b) where
  arbitrary = do
    a <- arbitrary
    b <- arbitrary
    return (Two a b)

type TwoAssoc a b = Two a b -> Two a b -> Two a b -> Bool

type TwoIdent a b = Two a b -> Bool

testTwoMonoid :: IO ()
testTwoMonoid = do
  quickCheck (sa :: TwoAssoc String String)
  quickCheck (mli :: TwoIdent String String)
  quickCheck (mlr :: TwoIdent String String)

-- BoolConj Bool
data BoolConj = BoolConj Bool deriving (Eq, Show)

instance Semigroup BoolConj where
  BoolConj True <> BoolConj True = BoolConj True
  _             <> _             = BoolConj False

instance Monoid BoolConj where
  mempty = BoolConj True
  mappend = (<>)

instance Arbitrary BoolConj where
  arbitrary = do
    a <- arbitrary
    return (BoolConj a)

type BoolConjAssoc = BoolConj -> BoolConj -> BoolConj -> Bool

type BoolConjIdent = BoolConj -> Bool

testBoolConjMonoid :: IO ()
testBoolConjMonoid = do
  quickCheck (sa :: BoolConjAssoc)
  quickCheck (mli :: BoolConjIdent)
  quickCheck (mlr :: BoolConjIdent)

-- BoolDisj Bool
data BoolDisj = BoolDisj Bool deriving (Eq, Show)

instance Semigroup BoolDisj where
  BoolDisj True <> _ = BoolDisj True
  _             <> BoolDisj True = BoolDisj True
  _             <> _             = BoolDisj False

instance Monoid BoolDisj where
  mempty = BoolDisj False
  mappend = (<>)

instance Arbitrary BoolDisj where
  arbitrary = do
    a <- arbitrary
    return (BoolDisj a)

type BoolDisjAssoc = BoolDisj -> BoolDisj -> BoolDisj -> Bool

type BoolDisjIdent = BoolDisj -> Bool

testBoolDisjMonoid :: IO ()
testBoolDisjMonoid = do
  quickCheck (sa :: BoolDisjAssoc)
  quickCheck (mli :: BoolDisjIdent)
  quickCheck (mlr :: BoolDisjIdent)

-- Combine a b
newtype Combine a b =
  Combine { unCombine :: (a -> b) }

instance Show (Combine a b) where
  show _ = "Combine <function>"

instance Semigroup b => Semigroup (Combine a b) where
  (Combine f) <> (Combine g) = Combine $ (\a -> (f a) <> (g a))

instance Monoid b => Monoid (Combine a b) where
  mempty = Combine $ \_ -> mempty
  mappend = (<>)

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

type CombineIdent = String -> Combine String String -> Bool

combineLeftIdent :: (Eq b, Monoid b) => a -> Combine a b -> Bool
combineLeftIdent x c =
  unCombine (mappend mempty c) x == unCombine c x

combineRightIdent :: (Eq b, Monoid b) => a -> Combine a b -> Bool
combineRightIdent x c =
  unCombine (mappend c mempty) x == unCombine c x

testCombineMonoid :: IO ()
testCombineMonoid = do
  quickCheck (combineAssoc :: CombineAssocType)
  quickCheck (combineLeftIdent :: CombineIdent)
  quickCheck (combineRightIdent :: CombineIdent)
-- testCombineAssoc :: IO ()
-- testCombineAssoc = quickCheck (semigroupAssoc :: CombineAssoc String String)

-- Comp a
newtype Comp a = Comp { unComp :: (a -> a) }

instance Show (Comp a) where
  show _ = "Comp <function>"

instance Semigroup (Comp a) where
  (Comp f) <> (Comp g) = Comp $ f . g

instance Monoid (Comp a) where
  mempty = Comp id
  mappend = (<>)

instance (CoArbitrary a, Arbitrary a) => Arbitrary (Comp a)  where
  arbitrary = do
    f <- arbitrary
    return (Comp f)

type CompAssocType = String -> Comp String -> Comp String  -> Comp String -> Bool
type CompIdentType = String -> Comp String -> Bool

compAssoc :: (Eq a) => a -> Comp a -> Comp a -> Comp a -> Bool
compAssoc x f g h =
  unComp (f <> (g <> h)) x == unComp ((f <> g) <> h) x

compMli :: (Eq a) => a -> Comp a -> Bool
compMli x f =
  unComp (mempty <> f) x == unComp f x
  
compMri :: (Eq a) => a -> Comp a -> Bool
compMri x f =
  unComp (f <> mempty) x == unComp f x

testCompMonoid :: IO ()
testCompMonoid = do
  quickCheck (compAssoc :: CompAssocType)
  quickCheck (compMli :: CompIdentType)
  quickCheck (compMri :: CompIdentType)
-- testCombineAssoc :: IO ()
-- testCombineAssoc = quickCheck (semigroupAssoc :: CombineAssoc String String)

-- Validation a b
data Validation a b = Fail a | Succ b
  deriving (Eq, Show)

instance Semigroup a => Semigroup (Validation a b) where
  (Succ a) <> _ = Succ a
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

-- State
newtype Mem s a =
  Mem {
    runMem :: s -> (a,s)
  }

instance Semigroup a => Semigroup (Mem s a) where
  (<>) = undefined

instance Monoid a => Monoid (Mem s a) where
  mempty = undefined
