import Data.List
import Data.Semigroup

-- some examples of composition
myLast :: [a] -> a
myLast = head . reverse

myMin :: Ord a => [a] -> a
myMin = head . sort

myMax :: Ord a => [a] -> a
myMax = myLast . sort

myAll :: (a -> Bool) -> [a] -> Bool
myAll testFunc = (foldr (&&) True) . (map testFunc)

-- QC 17.1
myAny :: (a -> Bool) -> [a] -> Bool
myAny testFunc = (foldr (||) False) . (map testFunc)

-- QC 17.2
-- No.   (/) neither works on Integers nor does it return Integers.

data Color = Red 
           | Yellow
           | Blue
           | Green
           | Purple
           | Orange
           | Brown 
           | Clear deriving (Eq, Show)

instance Semigroup Color where
  (<>) Clear a = a
  (<>) a Clear = a
  (<>) Red Blue = Purple
  (<>) Blue Red = Purple
  (<>) Yellow Blue = Green
  (<>) Blue Yellow = Green
  (<>) Yellow Red = Orange
  (<>) Red Yellow = Orange
  (<>) a b | a == b = a
           | all (`elem` [Red,Blue,Purple]) [a,b] = Purple
           | all (`elem` [Blue,Yellow,Green]) [a,b] = Green
           | all (`elem` [Red,Yellow,Orange]) [a,b] = Orange
           | otherwise = Brown

-- QC17.3
-- Yes, addition is associative
-- QC17.4: 1

data Events = Events [String] deriving (Eq, Show)
data Probs = Probs [Double] deriving (Eq, Show)
data PTable = PTable Events Probs

createPTable :: Events -> Probs -> PTable
createPTable events (Probs probs) = PTable events (Probs normalizedProbs)
  where totalProbs = sum probs
        normalizedProbs = map (\x -> x/totalProbs) probs

showPair :: String -> Double -> String
showPair event prob = mconcat [event, "|", show prob, "\n"]

instance Show PTable where
  show (PTable (Events events) (Probs probs)) = mconcat pairs
    where pairs = zipWith showPair events probs

coinFlip = createPTable (Events ["heads","tails"]) (Probs [0.5,0.5])

-- this function combines the cartesian product of two lists using a 
-- combining function.  To generate the cartesian product, you notice
-- we need to repeat each element in the first list once for each for
-- each element in the second, and then let zipWith handle pairing them up
-- we haven't been shown list comprehensions yet, which would be an easier
-- way to achieve this
cartCombine :: (a -> b -> c) -> [a] -> [b] -> [c]
cartCombine func l1 l2 = zipWith func newL1 cycledL2
  where nToAdd = length l2
        repeatedL1 = map (take nToAdd . repeat) l1
        newL1 = mconcat repeatedL1
        cycledL2 = cycle l2

-- just hyphening together the lists of events
combineEvents :: Events -> Events -> Events
combineEvents (Events e1) (Events e2) = Events $ cartCombine combiner e1 e2
  where combiner = (\x y -> mconcat [x,"-",y])

-- you multiple probabilities to combine them
combineProbs :: Probs -> Probs -> Probs
combineProbs (Probs p1) (Probs p2) = Probs $ cartCombine (*) p1 p2

instance Semigroup PTable where
  (<>) ptable1 (PTable (Events []) (Probs [])) = ptable1
  (<>) (PTable (Events []) (Probs [])) ptable2 = ptable2
  (<>) (PTable e1 p1) (PTable e2 p2) = createPTable newEvents newProbs
    where newEvents = combineEvents e1 e2
          newProbs = combineProbs p1 p2

instance Monoid PTable where
  mempty = PTable (Events []) (Probs [])
  mappend = (<>)

coin :: PTable
coin = coinFlip

spinner :: PTable
spinner = createPTable (Events ["red","blue","green"]) (Probs [0.1,0.2,0.7])

-- Q17.1
-- color modified above
instance Monoid Color where
  mempty = Clear
  mappend = (<>)

-- Q17.2
-- modifed Events and Probs all above
-- it was nice just letting the compiler tell me where to fix it to work
-- after the refactor
instance Semigroup Events where
  (<>) e1 (Events []) = e1
  (<>) (Events []) e2 = e2
  (<>) e1 e2 = combineEvents e1 e2

instance Monoid Events where
  mempty = Events []
  mappend = (<>)

instance Semigroup Probs where
  (<>) = combineProbs

instance Monoid Probs where
  mempty = Probs [1.0]
  mappend = (<>)
