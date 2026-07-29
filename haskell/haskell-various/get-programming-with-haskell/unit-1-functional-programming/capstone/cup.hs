
cup flOz = \message -> message flOz

littleCup = cup 6
coffeeCup = cup 12
bigGulp = cup 40

-- we're passing in the id function to get the value
getOz aCup = aCup (\flOz -> flOz)

drink aCup ozDrank = if ozDiff >= 0
                     then cup ozDiff
                     else cup 0
  where flOz = getOz aCup
        ozDiff = flOz - ozDrank

isEmpty aCup = getOz aCup == 0

afterManySips = foldl drink coffeeCup [1, 1, 1, 1, 1]
