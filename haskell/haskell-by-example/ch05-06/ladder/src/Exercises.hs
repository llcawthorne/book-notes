module Exercises (
  lMember,
  lMember',
  alter',
  member'',
  alter'',
  addEdges',
  buildDiGraph',
  deleteNode',
  deleteEdge',
) where

import qualified Data.AssocMap as M
import qualified Data.List as L
import Data.Maybe (isJust)

type DiGraph a = M.AssocMap a [a]

-- the official answer with isJust is prettier
lMember :: (Eq k) => k -> [(k, v)] -> Bool
lMember key xs = case (lookup key xs) of
  Just _ -> True
  _ -> False

lMember' :: (Eq k) => k -> [(k, v)] -> Bool
lMember' key xs = isJust (lookup key xs)

alter' :: (Eq k) => (Maybe v -> Maybe v) -> k -> [(k, v)] -> [(k, v)]
alter' f key [] =
  maybe [] (\value -> [(key, value)]) (f Nothing)
alter' f key ((key', value') : xs)
  | key == key' =
      maybe xs (\value -> (key, value) : xs) (f (Just value'))
  | otherwise =
      (key', value') : alter' f key xs

newtype AssocMap k v = AssocMap [(k, v)]
  deriving (Show)

-- What would these look like if we didn't make wrappers?
member'' :: (Eq k) => k -> AssocMap k v -> Bool
member'' _ (AssocMap []) = False
member'' x (AssocMap ((x', _) : xs))
  | x' == x = True
  | otherwise = member' x (AssocMap xs)

alter'' :: (Eq k) => (Maybe v -> Maybe v) -> k -> AssocMap k v -> AssocMap k v
alter'' f key (AssocMap []) =
  case f Nothing of
    Nothing -> AssocMap []
    Just value -> AssocMap [(key, value)]
alter'' f key (AssocMap ((key', value') : xs))
  | key == key' =
      case f (Just value') of
        Nothing -> AssocMap xs
        Just value -> AssocMap ((key, value) : xs)
  | otherwise =
      let AssocMap xs' = alter'' f key (AssocMap xs)
       in AssocMap ((key', value') : xs')

addEdge :: (Eq a) => (a, a) -> DiGraph a -> DiGraph a
addEdge (node, child) = M.alter insertEdge node
 where
  insertEdge Nothing = Just [child]
  insertEdge (Just nodes) =
    Just (L.nub (child : nodes))

-- I needed the books answer to factor out accumChange for addEdges' and
-- buildDiGraph'. I had the basic idea but didn't realize you could just
-- define a \(k, v) to replace the two parameter k v call for buildDiGraph
accumChange :: (a -> b -> b) -> [a] -> b -> b
accumChange _ [] acc = acc
accumChange f (x : xs) acc = accumChange f xs (f x acc)

addEdges' :: (Eq a) => [(a, a)] -> DiGraph a -> DiGraph a
addEdges' = accumChange addEdge

buildDiGraph' :: (Eq a) => [(a, [a])] -> DiGraph a
buildDiGraph' nodes = accumChange (\(k, v) acc -> M.insert k v acc) nodes M.empty

deleteNode' :: (Eq a) => a -> DiGraph a -> DiGraph a
deleteNode' = M.delete

deleteEdge' :: (Eq a) => (a, a) -> DiGraph a -> DiGraph a
deleteEdge' (node, child) = M.alter deleteEdge node
 where
  deleteEdge Nothing = Just []
  deleteEdge (Just nodes) =
    Just (L.delete child nodes)
