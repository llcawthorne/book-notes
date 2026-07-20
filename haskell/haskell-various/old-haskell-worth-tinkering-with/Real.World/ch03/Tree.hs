-- file: ch03/Tree.hs
data Tree a = Node a (Tree a) (Tree a)
            | Empty
              deriving (Show)

data MTree a = MNode a (Maybe (MTree a)) (Maybe (MTree a))
               deriving (Show)

aTree     = Node "doggy" (Node "adams" Empty Empty) Empty
maybeTree = MNode "doggy" (Just (MNode "froggy" Nothing Nothing)) Nothing
