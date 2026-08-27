{-# LANGUAGE ScopedTypeVariables #-}

module Exercises (
  lMember,
  lMember',
  alter',
  member'',
  alter'',
  addEdges',
  buildDiGraph',
  deleteNode,
  deleteEdge',
  dfsSearch,
  BiSearchState,
  biBfsSearch,
) where

import qualified Data.AssocMap as M
import qualified Data.List as L
import qualified Graph as G
import Data.Maybe (catMaybes, isJust)
import Data.Hashable (Hashable)

type DiGraph a = M.AssocMap a [a]
type SearchState a = ([a], DiGraph a, DiGraph a)

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
  | otherwise = member'' x (AssocMap xs)

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

deleteNode :: (Eq a) => a -> DiGraph a -> DiGraph a
deleteNode = M.delete

deleteEdge' :: (Eq a) => (a, a) -> DiGraph a -> DiGraph a
deleteEdge' (node, child) = M.alter deleteEdge node
 where
  deleteEdge Nothing = Just []
  deleteEdge (Just nodes) =
    Just (L.delete child nodes)

dfsSearch :: (Eq a) => DiGraph a -> a -> a -> Maybe [a]
dfsSearch graph start end
  | start == end = Just [start]
  | otherwise =
      let graph' = deleteNode start graph
          searches = [dfsSearch graph' c end | c <- G.children start graph]
       in case catMaybes searches of
            [] -> Nothing
            (xs : _) -> Just (start : xs)

type BiSearchState a = (SearchState a, SearchState a)

biBfsSearch :: forall a. (Hashable a, Eq a) => DiGraph a -> a -> a -> Maybe [a]
biBfsSearch graph start end
  | start == end = Just [start]
  | otherwise =
      let fState = ([start], graph, M.empty)
          bState = ([end], graph, M.empty)
       in biBfsSearch' (fState, bState)
  where
    findSolution :: DiGraph a -> a -> [a]
    findSolution g = go
      where
        go x =
          case G.children x g of
            [] -> [x]
            (v : _) -> x : go v

    checkOverlap :: BiSearchState a -> Maybe [a]
    checkOverlap ((fFrontier', _, fPreds'), (bFrontier', _, bPreds')) =
      let getSolution x =
            let fPath = findSolution fPreds' x
                bPath = findSolution bPreds' x
             in L.reverse fPath ++ L.tail bPath
          overlaps =
            L.filter (`M.member` bPreds') fFrontier'
          solutions =
            L.sortOn L.length (L.map getSolution overlaps)
       in if L.null solutions
            then Nothing
            else Just $ L.head solutions

    checkSolution :: SearchState a -> a -> Maybe [a]
    checkSolution (frontier, _, preds) node
      | node `L.elem` frontier = Just (findSolution preds node)
      | otherwise = Nothing

    biBfsSearch' :: BiSearchState a -> Maybe [a]
    biBfsSearch' state@(fState@(fFrontier, _, _), bState@(bFrontier, _, _))
      | L.null fFrontier && L.null bFrontier = Nothing
      | isJust fSol = fmap L.reverse fSol
      | isJust bSol = bSol
      | isJust overlapSol = overlapSol
      | otherwise = biBfsSearch' biState'
      where
        fSol = checkSolution fState end
        bSol = checkSolution bState start
        overlapSol = checkOverlap state
        fState' = bfsSearchStep fState
        bState' = bfsSearchStep bState
        biState' = (fState', bState')

    addMultiplePredecessors :: [(a, [a])] -> DiGraph a -> DiGraph a
    addMultiplePredecessors [] g = g
    addMultiplePredecessors ((n, ch) : xs) g =
      addMultiplePredecessors xs (go n ch g)
      where
        go n [] g = g
        go n (x : xs) g = go n xs (addEdge (x, n) g)

    bfsSearchStep :: SearchState a -> SearchState a
    bfsSearchStep (frontier, g, preds) =
      let g' = G.deleteNodes frontier g
          ch =
            L.map
              (\n -> (n, L.filter (`M.member` g') (G.children n g)))
              frontier
          frontier' = L.concatMap snd ch
          preds' = addMultiplePredecessors ch preds
       in (frontier', g', preds')
