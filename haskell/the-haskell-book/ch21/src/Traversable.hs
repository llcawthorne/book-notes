{-# LANGUAGE FlexibleContexts #-}
module Traversable where

import Data.Monoid
import Test.QuickCheck
import Test.QuickCheck.Checkers
import Test.QuickCheck.Classes

data Either' a b = Left' a | Right' b
  deriving (Eq, Ord, Show)

instance Functor (Either' a) where
  fmap _ (Left' x) = Left' x
  fmap f (Right' y) = Right' (f y)

instance Applicative (Either' e) where
  pure           = Right'
  Left'  e <*> _ = Left' e
  Right' f <*> r = fmap f r

instance Foldable (Either' a) where
  foldMap _ (Left' _) = mempty
  foldMap f (Right' y) = f y

  foldr _ z (Left' _) = z
  foldr f z (Right' y) = f y z

instance Traversable (Either' a) where
  traverse _ (Left' x) = pure (Left' x)
  traverse f (Right' y) = Right' <$> f y

instance (Arbitrary a, Arbitrary b) => Arbitrary (Either' a b) where
  arbitrary =  frequency [(1, Left' <$> arbitrary), (3, Right' <$> arbitrary)]

instance (Eq a, Eq b) => EqProp (Either' a b) where
  (=-=) = eq

newtype Identity' a = Identity' a
  deriving (Eq, Ord, Show)

instance Functor Identity' where
  fmap f (Identity' x) = Identity' (f x)

instance Applicative Identity' where
  pure           = Identity'
  Identity' f <*> i = fmap f i

instance Foldable Identity' where
  foldMap f (Identity' x) = f x
  foldr f z (Identity' x) = f x z

instance Traversable Identity' where
  traverse f (Identity' x) = Identity' <$> f x

instance Arbitrary a => Arbitrary (Identity' a)  where
  arbitrary = Identity' <$> arbitrary

instance Eq a => EqProp (Identity' a) where
  (=-=) = eq

newtype Constant' a b = Constant' { getConstant :: a}
  deriving (Eq, Ord, Show)

instance Functor (Constant' a) where
  fmap _ (Constant' a) = (Constant' a)

instance Monoid a => Applicative (Constant' a) where
  pure _                           = Constant' mempty
  (Constant' a) <*> (Constant' a') = Constant' (mappend a a')

instance Foldable (Constant' a) where
  foldMap _ (Constant' _) = mempty
  foldr _ z (Constant' _) = z

instance Traversable (Constant' a) where
  traverse _ (Constant' a) = pure (Constant' a)

instance Arbitrary a => Arbitrary (Constant' a b)  where
  arbitrary = Constant' <$> arbitrary

instance Eq a => EqProp (Constant' a b) where
  (=-=) = eq

data Optional a = Nada | Yep a
  deriving (Eq, Ord, Show)

instance Functor Optional where
  fmap _ Nada = Nada
  fmap f (Yep x) = Yep (f x)

instance Applicative Optional where
  pure           = Yep
  Nada  <*> _    = Nada
  _     <*> Nada = Nada
  Yep f <*> a    = fmap f a

instance Foldable Optional where
  foldMap _ Nada    = mempty
  foldMap f (Yep x) = f x
  foldr _ z Nada    = z
  foldr f z (Yep x) = f x z

instance Traversable Optional where
  traverse _ Nada    = pure Nada
  traverse f (Yep x) = Yep <$> f x

instance Arbitrary a => Arbitrary (Optional a)  where
  arbitrary = frequency [(1, return Nada), (3, Yep <$> arbitrary)]

instance Eq a => EqProp (Optional a) where
  (=-=) = eq

data List' a = Nil | Cons a (List' a)
  deriving (Eq, Ord, Show)

instance Functor List' where
  fmap _ Nil         = Nil
  fmap f (Cons x xs) = Cons (f x) (fmap f xs)

instance Applicative List' where
  pure x            = Cons x Nil
  Nil       <*> _   = Nil
  _         <*> Nil = Nil
  Cons f fs <*> l   = fmap f l `append` (fs <*> l)

append :: List' a -> List' a -> List' a
append Nil ys = ys
append (Cons x xs) ys = Cons x $ xs `append` ys

instance Foldable List' where
  foldMap _ Nil         = mempty
  foldMap f (Cons x xs) = f x <> foldMap f xs
  foldr _ z Nil         = z
  foldr f z (Cons x xs) = f x (foldr f z xs)

instance Traversable List' where
  traverse _ Nil         = pure Nil
  traverse f (Cons x xs) = Cons <$> f x <*> traverse f xs

instance Arbitrary a => Arbitrary (List' a)  where
  arbitrary = frequency [(1, return Nil), (3, Cons <$> arbitrary <*> arbitrary)]

instance Eq a => EqProp (List' a) where
  (=-=) = eq

data Three a b c = Three a b c
  deriving (Eq, Ord, Show)

instance Functor (Three a b) where
  fmap f (Three a b c) = Three a b (f c)

instance (Monoid a, Monoid b) => Applicative (Three a b) where
  pure                          = Three mempty mempty
  Three a b f <*> Three a' b' v = Three (a <> a') (b <> b') (f v)

instance Foldable (Three a b) where
  foldMap f (Three _ _ v) = f v
  foldr f z (Three _ _ v) = f v z

instance Traversable (Three a b) where
  traverse f (Three a b x) = Three a b <$> f x

instance (Arbitrary a, Arbitrary b, Arbitrary c) 
          => Arbitrary (Three a b c)  where
  arbitrary = Three <$> arbitrary <*> arbitrary <*> arbitrary

instance (Eq a, Eq b, Eq c) => EqProp (Three a b c) where
  (=-=) = eq

data Pair a b = Pair a b
  deriving (Eq, Ord, Show)

instance Functor (Pair a) where
  fmap f (Pair a x) = Pair a (f x)

instance Monoid a => Applicative (Pair a) where
  pure                   = Pair mempty
  Pair a f <*> Pair a' v = Pair (a <> a') (f v)

instance Foldable (Pair a) where
  foldMap f (Pair _ x) = f x
  foldr f z (Pair _ x) = f x z

instance Traversable (Pair a) where
  traverse f (Pair a x) = Pair a <$> f x

instance (Arbitrary a, Arbitrary b) => Arbitrary (Pair a b)  where
  arbitrary = Pair <$> arbitrary <*> arbitrary

instance (Eq a, Eq b) => EqProp (Pair a b) where
  (=-=) = eq

data Big a b = Big a b b
  deriving (Eq, Ord, Show)

instance Functor (Big a) where
  fmap f (Big a b b') = Big a (f b) (f b')

instance Monoid a => Applicative (Big a) where
  pure b                     = Big mempty b b
  Big a f f' <*> Big a' v v' = Big (a <> a') (f v) (f' v')

instance Foldable (Big a) where
  foldMap f (Big _ b b') = f b <> f b'
  foldr f z (Big _ b b') = f b (f b' z)

instance Monoid a => Traversable (Big a) where
  traverse f (Big a v v') = Big a <$> f v <*> f v'

instance (Arbitrary a, Arbitrary b) => Arbitrary (Big a b)  where
  arbitrary = Big <$> arbitrary <*> arbitrary <*> arbitrary

instance (Eq a, Eq b) => EqProp (Big a b) where
  (=-=) = eq

data Bigger a b = Bigger a b b b
  deriving (Eq, Ord, Show)

instance Functor (Bigger a) where
  fmap f (Bigger a v v' v'') = Bigger a (f v) (f v') (f v'')

instance Monoid a => Applicative (Bigger a) where
  pure b                                  = Bigger mempty b b b
  Bigger a f f' f'' <*> Bigger a' v v' v'' = 
    Bigger (a <> a') (f v) (f' v') (f'' v'')

instance Foldable (Bigger a) where
  foldMap f (Bigger _ v v' v'') = f v <> f v' <> f v''
  foldr f z (Bigger _ b b' b'') = f b (f b' (f b'' z))

instance Traversable (Bigger a) where
  traverse f (Bigger a v v' v'') = Bigger a <$> f v <*> f v' <*> f v''

instance (Arbitrary a, Arbitrary b) => Arbitrary (Bigger a b)  where
  arbitrary = Bigger <$> arbitrary <*> arbitrary <*> arbitrary <*> arbitrary

instance (Eq a, Eq b) => EqProp (Bigger a b) where
  (=-=) = eq

data S n a = S (n a) a deriving (Eq, Show)

instance Functor n => Functor (S n) where
  fmap f (S n a) = S (fmap f n) (f a)

instance Foldable n => Foldable (S n) where
  foldMap f (S n a) = foldMap f n <> f a
  foldr f z (S n a) = f a (foldr f z n)
  
instance Traversable n => Traversable (S n) where
  traverse f (S n a) = S <$> traverse f n <*> f a

instance (Functor n, Arbitrary (n a), Arbitrary a)
         => Arbitrary (S n a) where
  arbitrary = S <$> arbitrary <*> arbitrary

instance (Applicative n, Testable (n Property), Eq a, Eq (n a), EqProp a)
         => EqProp (S n a) where
  (=-=) = eq

data Tree a = Empty | Leaf a | Node (Tree a) a (Tree a)
  deriving (Eq, Show)

instance Functor Tree where
  fmap _ Empty          = Empty
  fmap f (Leaf a)       = Leaf $ f a
  fmap f (Node t1 a t2) = Node (fmap f t1) (f a) (fmap f t2)

instance Foldable Tree where
  foldMap _ Empty          = mempty
  foldMap f (Leaf a)       = f a
  foldMap f (Node t1 a t2) = (foldMap f t1) <> (f a) <> (foldMap f t2)
  foldr _ z Empty          = z
  foldr f z (Leaf a)       = f a z
  foldr f z (Node t1 a t2) = foldr f (f a (foldr f z t2)) t1
 
instance Traversable Tree where
  traverse _ Empty          = pure Empty
  traverse f (Leaf a)       = Leaf <$> f a
  traverse f (Node t1 a t2) = Node <$> traverse f t1 <*> f a <*> traverse f t2

instance Arbitrary a => Arbitrary (Tree a) where
  arbitrary = frequency 
    [
      (3, return Empty)
    , (3, Leaf <$> arbitrary)
    , (1, Node <$> arbitrary <*> arbitrary <*> arbitrary)
    ]

instance Eq a => EqProp (Tree a) where
  (=-=) = eq

runQC :: IO ()
runQC = do
  let trigger :: Either' String ([Int], [Int], Int, [Int])
      trigger = undefined
  quickBatch (traversable trigger)

  let trigger :: Identity' ([Int], [Int], Int, [Int])
      trigger = undefined
  quickBatch (traversable trigger)

  let trigger :: Constant' Int ([Int], [Int], Int, [Int])
      trigger = undefined
  quickBatch (traversable trigger)

  let trigger :: Optional ([Int], [Int], Int, [Int])
      trigger = undefined
  quickBatch (traversable trigger)

  let trigger :: List' (Sum Int, Sum Int, Int, Sum Int)
      trigger = undefined
  -- too slow to test
  quickBatch (traversable trigger)

  let trigger :: Three String String ([Int], [Int], Int, [Int])
      trigger = undefined
  quickBatch (traversable trigger)

  let trigger :: Pair String ([Int], [Int], Int, [Int])
      trigger = undefined
  quickBatch (traversable trigger)

  let trigger :: Big String (Sum Int, Sum Int, Int, Sum Int)
      trigger = undefined
  quickBatch (traversable trigger)

  let trigger :: Bigger String (Sum Int, Sum Int, Int, Sum Int)
      trigger = undefined
  quickBatch (traversable trigger)

  let trigger :: S Maybe (Sum Int, Sum Int, Int, Sum Int)
      trigger = undefined
  quickBatch (traversable trigger)

  let trigger :: Tree (Sum Int, Sum Int, Int, Sum Int)
      trigger = undefined
  quickBatch (traversable trigger)

