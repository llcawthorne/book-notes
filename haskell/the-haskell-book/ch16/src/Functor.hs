module Functor where

import Test.QuickCheck

functorIdentity :: (Functor f, Eq (f a)) => f a -> Bool
functorIdentity f = fmap id f == f

functorCompose :: (Eq (f c), Functor f) =>
                    (a -> b) -> (b -> c) -> f a -> Bool
functorCompose f g x =
  (fmap g (fmap f x)) == (fmap (g . f) x)

newtype Identity a = Identity a
  deriving (Eq, Show)

instance Functor Identity where
  fmap f (Identity a) = Identity (f a)

instance Arbitrary a => Arbitrary (Identity a) where
  arbitrary = do
    a <- arbitrary
    return (Identity a)

testIdentityCompose :: Fun Int Int -> Fun Int Int -> Identity Int -> Bool
testIdentityCompose (Fun _ f) (Fun _ g) x = functorCompose f g x

testIdentityFunc :: IO ()
testIdentityFunc = do
  quickCheck (functorIdentity :: Identity Int -> Bool)
  quickCheck testIdentityCompose

data Pair a = Pair a a
  deriving (Eq, Show)

instance Functor Pair where
  fmap f (Pair a a') = Pair (f a) (f a')

instance Arbitrary a => Arbitrary (Pair a) where
  arbitrary = do
    a <- arbitrary
    a' <- arbitrary
    return (Pair a a')

testPairCompose :: Fun Int Int -> Fun Int Int -> Pair Int -> Bool
testPairCompose (Fun _ f) (Fun _ g) x = functorCompose f g x

testPairFunc:: IO ()
testPairFunc = do
  quickCheck (functorIdentity :: Pair Int -> Bool)
  quickCheck testPairCompose

data Two a b = Two a b
  deriving (Eq, Show)

instance Functor (Two a) where
  fmap f (Two a b) = Two a (f b)

instance (Arbitrary a, Arbitrary b) => Arbitrary (Two a b) where
  arbitrary = do
    a <- arbitrary
    b <- arbitrary
    return (Two a b)

testTwoCompose :: Fun Int Int -> Fun Int Int -> Two String Int -> Bool
testTwoCompose (Fun _ f) (Fun _ g) x = functorCompose f g x

testTwoFunc:: IO ()
testTwoFunc = do
  quickCheck (functorIdentity :: Two String Int -> Bool)
  quickCheck testTwoCompose

data Three a b c = Three a b c
  deriving (Eq, Show)

instance Functor (Three a b) where
  fmap f (Three a b c) = Three a b (f c)

instance (Arbitrary a, Arbitrary b, Arbitrary c) => 
          Arbitrary (Three a b c) where
  arbitrary = do
    a <- arbitrary
    b <- arbitrary
    c <- arbitrary
    return (Three a b c)

testThreeCompose :: Fun Int Int -> Fun Int Int -> Three String Char Int -> Bool
testThreeCompose (Fun _ f) (Fun _ g) x = functorCompose f g x

testThreeFunc:: IO ()
testThreeFunc = do
  quickCheck (functorIdentity :: Three String Char Int -> Bool)
  quickCheck testThreeCompose

data Three' a b = Three' a b b
  deriving (Eq, Show)

instance Functor (Three' a) where
  fmap f (Three' a b b') = Three' a (f b) (f b')

instance (Arbitrary a, Arbitrary b) => Arbitrary (Three' a b) where
  arbitrary = do
    a <- arbitrary
    b <- arbitrary
    b' <- arbitrary
    return (Three' a b b')

testThree'Compose :: Fun Int Int -> Fun Int Int -> Three' String Int -> Bool
testThree'Compose (Fun _ f) (Fun _ g) x = functorCompose f g x

testThree'Func:: IO ()
testThree'Func = do
  quickCheck (functorIdentity :: Three' String Int -> Bool)
  quickCheck testThree'Compose

data Four a b c d = Four a b c d
  deriving (Eq, Show)

instance Functor (Four a b c) where
  fmap f (Four a b c d) = Four a b c (f d)

instance (Arbitrary a, Arbitrary b, Arbitrary c, Arbitrary d) => 
          Arbitrary (Four a b c d) where
  arbitrary = do
    a <- arbitrary
    b <- arbitrary
    c <- arbitrary
    d <- arbitrary
    return (Four a b c d)

testFourCompose :: 
  Fun Int Int -> Fun Int Int -> Four String Char String Int -> Bool
testFourCompose (Fun _ f) (Fun _ g) x = functorCompose f g x

testFourFunc:: IO ()
testFourFunc = do
  quickCheck (functorIdentity :: Four String Char String Int -> Bool)
  quickCheck testFourCompose

data Four' a b = Four' a a a b
  deriving (Eq, Show)

instance Functor (Four' a) where
  fmap f (Four' a a' a'' b) = Four' a a' a'' (f b)

instance (Arbitrary a, Arbitrary b) => Arbitrary (Four' a b) where
  arbitrary = do
    a <- arbitrary
    a' <- arbitrary
    a'' <- arbitrary
    b <- arbitrary
    return (Four' a a' a'' b)

testFour'Compose :: 
  Fun Int Int -> Fun Int Int -> Four' String Int -> Bool
testFour'Compose (Fun _ f) (Fun _ g) x = functorCompose f g x

testFour'Func:: IO ()
testFour'Func = do
  quickCheck (functorIdentity :: Four' String Int -> Bool)
  quickCheck testFour'Compose

data Possibly a = LolNope | Yeppers a
  deriving (Eq, Show)

instance Functor Possibly where
  fmap _ LolNope = LolNope
  fmap f (Yeppers a) = Yeppers (f a)

instance Arbitrary a => Arbitrary (Possibly a) where
  arbitrary = do
    a <- arbitrary
    oneof [return LolNope, return (Yeppers a)]

testPossCompose :: Fun Int Int -> Fun Int Int -> Possibly Int -> Bool
testPossCompose (Fun _ f) (Fun _ g) x = functorCompose f g x

testPossFunc:: IO ()
testPossFunc = do
  quickCheck (functorIdentity :: Possibly Int -> Bool)
  quickCheck testPossCompose

data Sum a b = First a | Second b
  deriving (Eq, Show)

instance Functor (Sum a) where
  fmap _ (First a) = First a
  fmap f (Second b) = Second (f b)

instance (Arbitrary a, Arbitrary b) => Arbitrary (Sum a b) where
  arbitrary = do
    a <- arbitrary
    b <- arbitrary
    oneof [return (First a), return (Second b)]

testSumCompose :: Fun Int Int -> Fun Int Int -> Sum String Int -> Bool
testSumCompose (Fun _ f) (Fun _ g) x = functorCompose f g x

testSumFunc:: IO ()
testSumFunc = do
  quickCheck (functorIdentity :: Sum String Int -> Bool)
  quickCheck testSumCompose

runTests :: IO ()
runTests = do
  testIdentityFunc
  testPairFunc
  testTwoFunc 
  testThreeFunc
  testThree'Func
  testFourFunc
  testFour'Func
  testPossFunc
  testSumFunc
