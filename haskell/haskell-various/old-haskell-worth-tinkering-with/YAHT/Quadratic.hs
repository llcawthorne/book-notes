module Quadratic
    where

-- Demonstates the 'let' ability.  Otherwise, this would look like:
-- roots a b c=
--      ((-b + sqrt (b*b - 4*a*c)) / (2*a),
--       (-b - sqrt (b*b - 4*a*c)) / (2*a))
roots a b c =
    let det = sqrt (b * b - 4 * a * c)
    in ((-b + det) / (2*a)
       ,(-b - det) / (2*a)
       )
