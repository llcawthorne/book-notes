module Exercises where

-- 1) *
-- 2) * -> *
--
-- String processing
-- 1)
notThe :: String -> Maybe String
notThe "the" = Nothing
notThe w     = Just w 

replaceThe :: String -> String
replaceThe s = unwords $ go (words s)
  where go []     = []
        go (x:xs) = case notThe x of
                       Nothing -> "a" : go xs
                       Just w  -> w   : go xs

-- 2)
countTheBeforeVowel :: String -> Integer
countTheBeforeVowel s = countTheBeforeVowel' (words s)
  where countTheBeforeVowel' :: [String] -> Integer
        countTheBeforeVowel' []       = 0
        countTheBeforeVowel' [x]      = 0
        countTheBeforeVowel' (x:y:xs) = 
          if x=="the" && elem (head y) "aeiou" 
          then 1 + countTheBeforeVowel' (y:xs)
          else 0 + countTheBeforeVowel' (y:xs)

-- 3)
countVowels :: String -> Int
countVowels = length . filter (`elem` "aeiou")

-- Validate the word
newtype Word' =
  Word' String
  deriving (Eq, Show)

vowels = "aeiou"
consonants = "bcdfghjklmnpqrstvwxyz"

mkWord :: String -> Maybe Word'
mkWord s
  | cVowels s > cCons s = Nothing
  | otherwise           = Just $ Word' s
  where cVowels = length . filter (`elem` vowels)
        cCons   = length . filter (`elem` consonants)

-- It's only Natural
data Nat =
    Zero
  | Succ Nat
  deriving (Eq, Show)

natToInteger :: Nat -> Integer
natToInteger Zero     = 0
natToInteger (Succ n) = 1 + natToInteger n

integerToNat :: Integer -> Maybe Nat
integerToNat n
  | n < 0     = Nothing
  | n == 0    = Just Zero
  | otherwise = Just $ Succ $ integerToNat' (n-1)
    where integerToNat' 0 = Zero
          integerToNat' n = Succ $ integerToNat' (n-1)

-- Small library for Maybe
-- 1)
isJust :: Maybe a -> Bool
isJust Nothing  = False
isJust (Just _) = True

isNothing :: Maybe a -> Bool
isNothing Nothing  = True
isNothing (Just _) = False
-- 2)
mayybee :: b -> (a -> b) -> Maybe a -> b
mayybee z _ Nothing  = z
mayybee _ f (Just x) = f x
-- 3)
fromMaybe :: a -> Maybe a -> a
fromMaybe z Nothing  = z
fromMaybe _ (Just x) = x
-- 4)
listToMaybe :: [a] -> Maybe a
listToMaybe []     = Nothing
listToMaybe (x:xs) = Just x

maybeToList :: Maybe a -> [a]
maybeToList Nothing  = []
maybeToList (Just x) = [x]
-- 5)
catMaybes :: [Maybe a] -> [a]
catMaybes []            = []
catMaybes (Nothing:xs)  = catMaybes xs
catMaybes ((Just x):xs) = x : catMaybes xs
-- 6)
flipMaybe :: (Eq a) => [Maybe a] -> Maybe [a]
flipMaybe [] = Just []
flipMaybe xs 
  | Nothing `elem` xs = Nothing
  | otherwise         = Just $ flipMaybe' xs
  where flipMaybe' []            = []
        flipMaybe' ((Just x):xs) = x : flipMaybe' xs

-- Small library for either
-- 1)
lefts' :: [Either a b] -> [a]
lefts' xs = foldr f [] xs
  where f (Left x) acc  = x : acc
        f (Right _) acc = acc
-- 2)
rights' :: [Either a b] -> [b]
rights' xs = foldr f [] xs
  where f (Left _) acc  = acc
        f (Right x) acc = x : acc
-- 3)
partitionEithers' :: [Either a b] -> ([a], [b])
partitionEithers' xs = foldr f ([],[]) xs
  where f (Left x) acc  = (x:fst acc, snd acc)
        f (Right x) acc = (fst acc, x:snd acc)
-- 4)
eitherMaybe' :: (b -> c) -> Either a b -> Maybe c
eitherMaybe' _ (Left x)  = Nothing
eitherMaybe' f (Right x) = Just $ f x
-- 5)
either' :: (a -> c) -> (b -> c) -> Either a b -> c
either' f _ (Left x)  = f x
either' _ f (Right x) = f x
-- 6)
eitherMaybe'' :: (b -> c) -> Either a b -> Maybe c
eitherMaybe'' f e = either' (\x -> Nothing) (\x -> Just $ f x) e

eitherMaybe''' :: (b -> c) -> Either a b -> Maybe c
eitherMaybe''' f = either' (const Nothing) (Just . f)

-- Unfolds
-- 1)
myIterate :: (a -> a) -> a -> [a]
myIterate f x = x : myIterate f (f x)
-- 2)
myUnfoldr :: (b -> Maybe (a, b)) -> b -> [a]
myUnfoldr f x = case f x of
                Just x' -> fst x' : myUnfoldr f (snd x')
                Nothing -> []
-- 3)
betterIterate :: (a -> a) -> a -> [a]
betterIterate f x = myUnfoldr (\b -> Just (b, f b)) x

-- Finally something other than a list!
data BinaryTree a =
    Leaf
  | Node (BinaryTree a) a (BinaryTree a)
  deriving (Eq, Ord, Show)

-- 1)
unfold :: (a -> Maybe (a, b, a)) -> a -> BinaryTree b
unfold f x = case f x of
             Just (a, b, a') -> Node (unfold f a) b (unfold f a')
             Nothing         -> Leaf
-- 2)
treeBuild :: Integer -> BinaryTree Integer
treeBuild n = unfold (\x -> case x of 
                            0 -> Nothing
                            x -> Just (x-1, x-1, x-1)) n 

-- I've done something wrong with my trees, the values are reversed from
-- the book
