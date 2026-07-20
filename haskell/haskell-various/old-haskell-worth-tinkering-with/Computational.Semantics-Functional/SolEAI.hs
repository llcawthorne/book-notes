module SolEAI where 

import FSynF
import Model
import Model2
import TCOM 
import EAI 

cnINT :: CN -> World -> Entity -> Bool
cnINT Girl = iGirl
cnINT Princess = iPrincess

intensCN :: CN -> IEntity -> IBool
intensCN = iProp . cnINT

npINT :: NP -> World -> (Entity -> Bool) -> Bool
npINT np = \ i -> intNP np 

intensNP :: NP -> (IEntity -> IBool) -> IBool
intensNP = iPropToB . npINT

