module Monad where

import Test.QuickCheck
import Test.QuickCheck.Checkers
import Test.QuickCheck.Classes

data Sum a b = First a | Second b
  deriving (Eq, Show)

instance Functor (Sum a) where
  fmap _ (First l) = First l
  fmap f (Second r) = Second $ f r

instance Applicative (Sum a) where
  pure = Second
  First l <*> _ = First l
  _ <*> First l = First l
  Second f <*> Second x = Second $ f x

instance Monad (Sum a) where
  return = pure
  First l >>= _ = First l
  Second r >>= k = k r

instance (Arbitrary e, Arbitrary a) => Arbitrary (Sum e a) where
  arbitrary = frequency [(1, First <$> arbitrary)
                        ,(3, Second <$> arbitrary)]

instance (Eq e, Eq a) => EqProp (Sum e a) where
  (=-=) = eq

data Nope a = NopeDotJpg
  deriving (Eq, Show)

instance Functor Nope where
  fmap _ NopeDotJpg = NopeDotJpg

instance Applicative Nope where
  pure = \_ -> NopeDotJpg
  NopeDotJpg <*> NopeDotJpg = NopeDotJpg

instance Monad Nope where
  return = pure
  NopeDotJpg >>= _ = NopeDotJpg

instance Arbitrary (Nope a) where
  arbitrary = return NopeDotJpg

instance EqProp (Nope a) where
  (=-=) = eq

data BahEither b a = PLeft a | PRight b
  deriving (Eq, Show)

instance Functor (BahEither b) where
  fmap _ (PRight r) = PRight r
  fmap f (PLeft l) = PLeft $ f l

instance Applicative (BahEither b) where
  pure = PLeft
  PRight r <*> _ = PRight r
  _ <*> PRight r = PRight r
  PLeft f <*> PLeft l = PLeft $ f l

instance Monad (BahEither b) where
  return = pure
  PRight r >>= _ = PRight r
  PLeft l >>= k = k l

instance (Arbitrary b, Arbitrary a) => Arbitrary (BahEither b a) where
  arbitrary = frequency [(1, PRight <$> arbitrary)
                        ,(3, PLeft <$> arbitrary)]

instance (Eq b, Eq a) => EqProp (BahEither b a) where
  (=-=) = eq

newtype Identity a = Identity a
  deriving (Eq, Show)

instance Functor Identity where
  fmap f (Identity a) = Identity $ f a

instance Applicative Identity where
  pure = Identity
  Identity f <*> Identity a = Identity $ f a

instance Monad Identity where
  return = pure
  Identity a >>= k = k a

instance Arbitrary a => Arbitrary (Identity a) where
  arbitrary = Identity <$> arbitrary

instance Eq a => EqProp (Identity a) where
  (=-=) = eq

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

instance Monad List where
  return = pure
  xs >>= f = flatMap f xs

instance Arbitrary a => Arbitrary (List a) where
  arbitrary = frequency [(1, return Nil)
                        ,(10, Cons <$> arbitrary <*> arbitrary)]

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

runQC :: IO ()
runQC = do
  let trigger :: Sum String (Int, Int, Int)
      trigger = undefined
  quickBatch $ functor trigger
  quickBatch $ applicative trigger
  quickBatch $ monad trigger
  let trigger :: Nope (Int, Int, Int)
      trigger = undefined
  quickBatch $ functor trigger
  quickBatch $ applicative trigger
  quickBatch $ monad trigger
  let trigger :: BahEither String (Int, Int, Int)
      trigger = undefined
  quickBatch $ functor trigger
  quickBatch $ applicative trigger
  quickBatch $ monad trigger
  let trigger :: Identity (Int, Int, Int)
      trigger = undefined
  quickBatch $ functor trigger
  quickBatch $ applicative trigger
  quickBatch $ monad trigger
  let trigger :: List (Int, Int, Int)
      trigger = undefined
  quickBatch $ functor trigger
  quickBatch $ applicative trigger
  quickBatch $ monad trigger

j :: Monad m => m (m a) -> m a
j m = m >>= id

l1 :: Monad m => (a -> b) -> m a -> m b
l1 f m = f <$> m

l2 :: Monad m => (a -> b -> c) -> m a -> m b -> m c
l2 f m m' = m >>= \a -> m' >>= \b -> pure (f a b)

a :: Monad m => m a -> m (a -> b) -> m b
a m m' = m' >>= \f -> m >>= \a -> pure (f a)

meh :: Monad m => [a] -> (a -> m b) -> m [b]
meh as f = go $ map f as
  where go :: Monad m => [m b] -> m [b]
        go [] = pure []
        go (mb : mbs) = mb >>= \b -> (go mbs) >>= \bs -> pure (b : bs)

flipType :: (Monad m) => [m a] -> m [a]
flipType as = meh as id
