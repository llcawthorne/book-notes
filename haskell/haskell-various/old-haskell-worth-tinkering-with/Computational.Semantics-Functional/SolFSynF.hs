module SolFSynF where 

import Data.List
import FSynF 

opsNr :: Form -> Int
opsNr (P _)    = 0 
opsNr (Ng f)   = 1 + opsNr f
opsNr (Cnj fs) = 1 + sum (map opsNr fs)
opsNr (Dsj fs) = 1 + sum (map opsNr fs)

depth :: Form -> Int
depth (P _)    = 0 
depth (Ng f)   = 1 + depth f
depth (Cnj []) = 1 
depth (Cnj fs) = 1 + maximum (map depth fs)
depth (Dsj []) = 1 
depth (Dsj fs) = 1 + maximum (map depth fs)

propNames :: Form -> [String]
propNames (P name) = [name]
propNames (Ng f)   = propNames f
propNames (Cnj fs) = (sort.nub.concat) (map propNames fs)
propNames (Dsj fs) = (sort.nub.concat) (map propNames fs)

