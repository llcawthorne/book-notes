module Foldable where

import Data.Monoid

sum' :: (Foldable t, Num a) => t a -> a
sum' = foldr (+) 0
sum'' :: (Foldable t, Num a) => t a -> a
sum'' = getSum . foldMap Sum

product' :: (Foldable t, Num a) => t a -> a 
product' = foldr (*) 1
product'' :: (Foldable t, Num a) => t a -> a 
product'' = getProduct . foldMap Product

elem' :: (Foldable t, Eq a) => a -> t a -> Bool
elem' a = getAny . foldMap (\x -> Any (x == a))

minimum' :: (Foldable t, Ord a) => t a -> Maybe a
minimum' = foldr go Nothing
  where go x Nothing = Just x
        go x (Just y) = if x < y then Just x else Just y

null' :: (Foldable t) => t a -> Bool
null' = getAll . foldMap (\_ -> All False)

length' :: (Foldable t) => t a -> Int
length' = getSum . foldMap (\_ -> Sum 1) 

toList' :: (Foldable t) => t a -> [a]
toList' = foldMap (\x -> [x])

-- | Combine the elements of a structure using a monoid.
fold' :: (Foldable t, Monoid m) => t m -> m
fold' = foldMap id

foldMap' :: (Foldable t, Monoid m) => (a -> m) -> t a -> m
foldMap' f = foldr (\x acc -> mappend (f x) acc) mempty

data Constant a b = Constant b
instance Foldable (Constant a) where
  foldMap f (Constant b) = f b

data Two a b = Two a b
instance Foldable (Two a) where
  foldMap f (Two _ b) = f b

data Three a b c = Three a b c
instance Foldable (Three a b) where
  foldMap f (Three _ _ c) = f c

data Three' a b = Three' a b b
instance Foldable (Three' a) where
  foldMap f (Three' _ b b') = f b <> f b'

data Four' a b = Four' a b b b
instance Foldable (Four' a) where
  foldMap f (Four' _ b b' b'') = f b <> f b' <> f b''

filterF :: (Applicative f, Foldable t , Monoid (f a))
        => (a -> Bool) -> t a -> f a
filterF f = foldMap (\x -> if f x then pure x else mempty)
