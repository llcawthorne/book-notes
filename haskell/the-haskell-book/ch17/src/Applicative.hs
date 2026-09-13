module Applicative where

import Control.Applicative
import Data.Monoid
import qualified Test.QuickCheck as QC
import Test.QuickCheck.Checkers
import Test.QuickCheck.Classes

newtype Identity a = Identity a
  deriving (Eq, Ord, Show)

instance Functor Identity where
  fmap f (Identity a) = Identity $ f a

instance Applicative Identity where
  pure = Identity
  Identity f <*> Identity a = Identity $ f a

newtype Constant a b = Constant { getConstant :: a }
  deriving (Eq, Ord, Show)

instance Functor (Constant a) where
  fmap _ (Constant a) = Constant a

instance Monoid a => Applicative (Constant a) where
  pure _ = Constant mempty
  (Constant a) <*> (Constant a') = Constant (mappend a a')

data List a = Nil | Cons a (List a)
  deriving (Eq, Show)

instance Functor List where
  fmap _ Nil = Nil
  fmap f (Cons x xs) = Cons (f x) (fmap f xs)

instance Applicative List where
  pure a = Cons a (Nil)
  Nil <*> _ = Nil
  _ <*> Nil = Nil
  Cons f xs <*> Cons y ys = fmap f (Cons y ys) `append` (xs <*> (Cons y ys))

instance QC.Arbitrary a => QC.Arbitrary (List a) where
  arbitrary = QC.oneof [return Nil, Cons <$> QC.arbitrary <*> QC.arbitrary]

instance Eq a => EqProp (List a) where
  (=-=) = eq

append :: List a -> List a -> List a
append Nil ys = ys
append (Cons x xs) ys = Cons x $ xs `append` ys

fold :: (a -> b -> b) -> b -> List a -> b
fold _ b Nil        = b
fold f b (Cons h t) = f h (fold f b t)

concat' :: List (List a) -> List a
concat' = fold append Nil

flatMap :: (a -> List b) -> List a -> List b
flatMap f as = concat' (fmap f as)

newtype ZipList' a = ZipList' [a]
  deriving (Eq, Show)

instance Eq a => EqProp (ZipList' a) where
  xs =-= ys = xs' `eq` ys'
    where xs' = let (ZipList' l) = xs
                 in take 3000 l
          ys' = let (ZipList' l) = ys
                 in take 3000 l

instance Functor ZipList' where
  fmap f (ZipList' xs) = ZipList' $ fmap f xs

instance QC.Arbitrary a => QC.Arbitrary (ZipList' a) where
  arbitrary = ZipList' <$> QC.arbitrary

instance Applicative ZipList' where
  pure x = ZipList' $ repeat x
  (ZipList' fs') <*> (ZipList' ys') = ZipList' $ go fs' ys'
    where go [] _ = []
          go _ [] = []
          go (f:fs) (y:ys) = (f y) : go fs ys

data Validation e a = Failure e | Success a
  deriving (Eq, Show)

instance Functor (Validation e) where
  fmap _ (Failure f) = Failure f
  fmap f (Success a) = Success $ f a

instance Monoid e => Applicative (Validation e) where
  pure x = Success x
  (Failure f) <*> (Failure f') =  Failure $ f <> f'
  (Failure f) <*> _ = Failure f
  _ <*> (Failure f) = Failure f
  Success f <*> Success x = Success (f x)

instance (QC.Arbitrary a, QC.Arbitrary e) => QC.Arbitrary (Validation e a) where
  arbitrary = QC.oneof [Failure <$> QC.arbitrary
                       ,Success <$> QC.arbitrary]

instance (Eq e , Eq a) => EqProp (Validation e a) where
  (=-=) = eq

runQC :: IO ()
runQC = do
  quickBatch (applicative (Cons (1, 2, 3) Nil :: List (Int, Int, Int)))
  quickBatch (applicative (ZipList' [(1, 2, 3)] :: ZipList' (Int, Int, Int)))
  quickBatch (applicative 
    (Success (1, 2, 3) :: Validation [String] (Int, Int, Int)))
