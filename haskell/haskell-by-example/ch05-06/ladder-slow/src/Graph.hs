{-# LANGUAGE ScopedTypeVariables #-}

module Graph (
  Graph,
  DiGraph,
  hasNode,
  addEdge,
  addEdges,
  deleteNode,
  deleteNodes,
  buildDiGraph,
  children,
  bfsSearch,
) where

import qualified Data.AssocMap as M
import qualified Data.List as L

type Graph a = [(a, a)]
type DiGraph a = M.AssocMap a [a]

empty :: DiGraph a
empty = M.empty

hasNode :: (Eq a) => DiGraph a -> a -> Bool
hasNode = flip M.member

addEdge :: (Eq a) => (a, a) -> DiGraph a -> DiGraph a
addEdge (node, child) = M.alter insertEdge node
 where
  insertEdge Nothing = Just [child]
  insertEdge (Just nodes) =
    Just (L.nub (child : nodes))

addEdges :: (Eq a) => [(a, a)] -> DiGraph a -> DiGraph a
addEdges [] graph = graph
addEdges (edge : edges) graph = addEdge edge (addEdges edges graph)

deleteNode :: (Eq a) => a -> DiGraph a -> DiGraph a
deleteNode = M.delete

deleteNodes :: Eq a => [a] -> DiGraph a -> DiGraph a
deleteNodes [] graph = graph
deleteNodes (x : xs) graph = M.delete x (deleteNodes xs graph)

buildDiGraph :: (Eq a) => [(a, [a])] -> DiGraph a
buildDiGraph nodes = go nodes M.empty
 where
  go [] graph = graph
  go ((key, value) : xs) graph = M.insert key value (go xs graph)

children :: (Eq a) => a -> DiGraph a -> [a]
children = M.findWithDefault []

type SearchState a = ([a], DiGraph a, DiGraph a)
data SearchResult a = Unsuccessful | Successful (DiGraph a)

bfsSearch :: forall a. Eq a => DiGraph a -> a -> a -> Maybe [a]
bfsSearch graph start end
  | start == end = Just [start]
  | otherwise =
    case bfsSearch' ([start], graph, empty) of
      Successful preds -> Just (findSolution preds)
      Unsuccessful -> Nothing
  where
    findSolution :: DiGraph a -> [a]
    findSolution g = L.reverse (go end)
      where
        go x =
          case children x g of
            [] -> [x]
            (v : _) -> x : go v

    addMultiplePredecessors :: Eq a => [(a, [a])] -> DiGraph a -> DiGraph a
    addMultiplePredecessors [] g = g
    addMultiplePredecessors ((n, ch) : xs) g =
      addMultiplePredecessors xs (go n ch g)
      where
        go n [] g = g
        go n (x :xs) g = go n xs (addEdge (x, n) g)

    bfsSearch' :: Eq a => SearchState a -> SearchResult a
    bfsSearch' ([], _, preds) = Unsuccessful
    bfsSearch' (frontier, g, preds) =
      let g' = deleteNodes frontier g
          ch =
            L.map
              (\n -> (n, L.filter (`M.member` g') (children n g)))
              frontier
          frontier' = L.concatMap snd ch
          preds' = addMultiplePredecessors ch preds
       in if end `L.elem` frontier'
            then Successful preds'
            else bfsSearch' (frontier', g', preds')
