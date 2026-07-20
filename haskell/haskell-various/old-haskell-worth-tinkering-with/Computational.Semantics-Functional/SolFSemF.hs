module SolFSemF where 

import FSynF
import FSemF
import InfEngine
import System.Random  

impliesL :: [Form] -> Form -> Bool
impliesL = implies . Cnj 

propEquiv :: Form -> Form -> Bool
propEquiv f1 f2 = implies f1 f2 && implies f2 f1

altEval :: [String] -> Form -> Bool
altEval [] (P c)    = False 
altEval (i:xs) (P c)
     | c == i    = True 
     | otherwise = altEval xs (P c)
altEval xs (Ng f)   = not (altEval xs f)
altEval xs (Cnj fs) = all (altEval xs) fs
altEval xs (Dsj fs) = any (altEval xs) fs

getColours :: IO [Colour]
getColours = do 
              i <- getStdRandom (randomR (0,4))
              j <- getStdRandom (randomR (0,4))
              k <- getStdRandom (randomR (0,4))
              l <- getStdRandom (randomR (0,4))
              return [toEnum i,toEnum j, toEnum k, toEnum l]

playgame :: [Colour] -> IO()
playgame secret = 
   do    
    putStrLn "Give a sequence of four colours from RGBYO"
    str <- getLine
    let guess = string2pattern str in  
      if guess /= secret 
        then 
          let answer = reaction secret guess in 
          do 
            putStrLn (show answer)
            putStrLn "Please make another guess"
            playgame secret
        else putStrLn "correct"

mm :: IO ()
mm = 
  do 
    secret <- getColours
    playgame secret

stupid :: [Pattern] -> Pattern -> Bool
stupid state guess = notElem guess state

startState :: [Pattern]
startState = let colours = [minBound..maxBound] in 
   [ [c1,c2,c3,c4] | c1 <- colours, c2 <- colours, 
                     c3 <- colours, c4 <- colours ]

play :: IO()
play = play0 startState

play0 :: [Pattern] -> IO()
play0 state = 
  do 
    putStrLn "Give a sequence of four colours from RGBYO"
    str <- getLine 
    let guess = string2pattern str in 
      do 
        if stupid state guess 
          then putStrLn "Not very clever"
          else putStrLn "Hmm, clever guess.."
        if guess /= secret 
         then 
           let answer = reaction secret guess in 
             do 
               putStrLn (show answer)
               putStrLn "Please make another guess"
               play0 (updateMM state guess answer) 
         else putStrLn "correct"

mention :: Class -> (Class, Class, Bool) -> Bool
mention xs (ys, zs, _) = 
   elem xs [ys,zs] || elem (opp xs) [ys,zs]

filterKB :: Class -> KB -> KB
filterKB xs = filter (mention xs)

report :: KB -> Class -> [Statement]
report kb as = map f2s (filterKB as kb)

