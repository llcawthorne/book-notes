-- file: ch03/AlgebraicVector.hs
-- because these two are different types, we cannot
-- compare them with simple (==) even though they are
-- both a pair of Double values.  
-- this makes sense, as they represent different things.
--
-- x and y coordinates or lengths.
data Cartesian2D = Cartesian2D Double Double
                   deriving (Eq, Show)

-- Angle and distance (magnitude).
data Polar2D = Polar2D Double Double
               deriving (Eq, Show)
