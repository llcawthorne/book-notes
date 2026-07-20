-- Priority Queues, using heaps.
--
-- Based on code by L. Paulson in _ML for the Working Programmer_.
--
-- Adapted for Haskell by Melissa O'Neill.
--
-- Code may be used freely, as long as attributions remain accurate.  

module PriorityQ (PriorityQ, empty, isEmpty, minKeyValue, minKey, minValue,
                  insert, deleteMin, deleteMinAndInsert) where

data PriorityQ k v = Lf
                   | Br {-# UNPACK #-} !k v !(PriorityQ k v) !(PriorityQ k v)
               deriving (Eq, Ord, Read, Show)

empty :: PriorityQ k v
empty = Lf

isEmpty :: PriorityQ k v -> Bool
isEmpty Lf  = True
isEmpty _   = False

minKeyValue :: PriorityQ k v -> (k, v)
minKeyValue (Br k v _ _)    = (k,v)
minKeyValue _               = error "Empty heap!"

minKey :: PriorityQ k v -> k
minKey (Br k v _ _)         = k
minKey _                    = error "Empty heap!"

minValue :: PriorityQ k v -> v
minValue (Br k v _ _)       = v
minValue _                  = error "Empty heap!"

insert :: Ord k => k -> v -> PriorityQ k v -> PriorityQ k v
insert wk wv (Br vk vv t1 t2)
               | wk <= vk   = Br wk wv (insert vk vv t2) t1
               | otherwise  = Br vk vv (insert wk wv t2) t1
insert wk wv Lf             = Br wk wv Lf Lf

siftdown :: Ord k => k -> v -> PriorityQ k v -> PriorityQ k v -> PriorityQ k v
siftdown wk wv Lf _             = Br wk wv Lf Lf
siftdown wk wv (t @ (Br vk vv _ _)) Lf 
    | wk <= vk                  = Br wk wv t Lf
    | otherwise                 = Br vk vv (Br wk wv Lf Lf) Lf
siftdown wk wv (t1 @ (Br vk1 vv1 p1 q1)) (t2 @ (Br vk2 vv2 p2 q2))
    | wk <= vk1 && wk <= vk2    = Br wk wv t1 t2
    | vk1 <= vk2                = Br vk1 vv1 (siftdown wk wv p1 q1) t2
    | otherwise                 = Br vk2 vv2 t1 (siftdown wk wv p2 q2) 

deleteMinAndInsert :: Ord k => k -> v -> PriorityQ k v -> PriorityQ k v
deleteMinAndInsert wk wv Lf             = error "Empty PriorityQ"
deleteMinAndInsert wk wv (Br _ _ t1 t2) = siftdown wk wv t1 t2

leftrem :: PriorityQ k v -> (k, v, PriorityQ k v)
leftrem (Br vk vv Lf Lf) = (vk, vv, Lf)
leftrem (Br vk vv t1 t2) = (wk, wv, Br vk vv t t2) where
    (wk, wv, t) = leftrem t1
leftrem _                = error "Empty heap!"

deleteMin :: Ord k => PriorityQ k v -> PriorityQ k v
deleteMin (Br vk vv Lf _) = Lf
deleteMin (Br vk vv t1 t2) = siftdown wk wv t2 t where
    (wk,wv,t) = leftrem t1
deleteMin _ = error "Empty heap!"

