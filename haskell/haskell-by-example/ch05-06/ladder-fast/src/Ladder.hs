module Ladder (
  Dictionary,
  readDictionary,
  ladderSolve,
)
where

import qualified Data.List as L
import qualified Graph as G
import qualified PermutationMap as PM

type Dictionary = [String]

readDictionary :: FilePath -> IO Dictionary
readDictionary filepath = do
  dictionaryContent <- readFile filepath
  let
    lines = L.lines dictionaryContent
    words = L.map (L.filter (`L.elem` ['a' .. 'z'])) lines
  return (L.nub words)

mkLadderGraph :: Dictionary -> G.DiGraph String
mkLadderGraph dict = G.buildDiGraph nodes
 where
  map = PM.createPermutationMap dict
  nodes =
    L.map (\w -> (w, computeCandidates map w)) dict

-- function to compute valid candidates for the game's next step
computeCandidates :: PM.PermutationMap -> String -> [String]
computeCandidates map word =
  -- a candidate is one letter added, one removed, or one modified
  let candidates = modified ++ removed ++ added ++ [word]
      -- sort all possible candidates and remove duplicates
      uniques = L.nub [L.sort w | w <- candidates]
      -- compute all valid permutations for each possible candidate
      perms = L.concatMap (\x -> PM.findWithDefault [] x map) uniques
   in -- remove the original word from the valid candidates
      L.delete word perms
 where
  added = [x : word | x <- ['a' .. 'z']]
  removed = [L.delete x word | x <- word]
  modified =
    [x : L.delete y word | x <- ['a' .. 'z'], y <- word, x /= y]

ladderSolve :: Dictionary -> String -> String -> Maybe [String]
ladderSolve dict start end =
  let g = mkLadderGraph dict
   in G.bfsSearch g start end
