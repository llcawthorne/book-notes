module SolCAIA where 

import List
import CAIA

q1,q2,q3,q4 :: Form
q1 = Prop (Q 1); q2 = Prop (Q 2)
q3 = Prop (Q 3); q4 = Prop (Q 4)

initWise :: EpistM Integer
initWise = 
  Mo states 
     [a..d]
     valuation
     (computeAcc a states [Q 1, Q 2, Q 3, Q 4] valuation
      ++
      computeAcc b states [Q 2, Q 3, Q 4] valuation
      ++
      computeAcc c states [Q 3, Q 4] valuation
      ++
      computeAcc d states [Q 1, Q 2, Q 3, Q 4] valuation)
     [10]
  where 
  states = [0..15]
  valuation = zip states (powerList [Q 1, Q 2, Q 3, Q 4])

capsInfo :: Form
capsInfo = 
  Disj [Conj [f, g, Neg h, Neg j] | 
              f <- [q1, q2, q3, q4], 
              g <- [q1, q2, q3, q4] \\ [f],
              h <- [q1, q2, q3, q4] \\ [f,g],
              j <- [q1, q2, q3, q4] \\ [f,g,h], 
              f < g, h < j                     ]

mo1 = convert (upd_pa initWise capsInfo)

cKnows = Disj [K (Agent c) q3, K (Agent c) (Neg q3)]

mo2 = convert (upd_pa mo1 (Neg cKnows)) 

bKnows = Disj [K (Agent b) q2, K (Agent b) (Neg q2)]

test = isTrue mo2 bKnows

male      = Prop (R 1)
adult     = Prop (R 2) 
unmarried = Prop (R 3)

