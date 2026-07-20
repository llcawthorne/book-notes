-- file: ch03/ShapeUnion.hs
-- using algebraic data types like a union from C/C++

type Point  = (Double, Double)
type Center = Point
type Radius = Double

data Shape = Circle Center Radius
           | Poly [Point]
             deriving (Eq, Show)

unitCircle = Circle (0.0, 0.0) 1
