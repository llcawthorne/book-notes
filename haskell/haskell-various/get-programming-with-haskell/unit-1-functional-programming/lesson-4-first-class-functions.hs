import Data.List

ifEven f x = if even x
             then f x
             else x

inc n = n + 1
double n = n * 2
square n = n^2

ifEvenInc n = ifEven inc n
ifEvenDouble = ifEven double
ifEvenSquare = ifEven square
ifEvenNegate = ifEven (\x -> -x)

-- QC 4.1
ifEvenCube = ifEven (\x -> x^3)

names = [("Ian", "Curtis"),
         ("Bernard", "Sumner"),
         ("Peter", "Hook"),
         ("Stephen", "Morris")]

sortedNames = sort names
sortedLast = sortBy (\a b -> compare (snd a) (snd b)) names

compareBothNames name1 name2 = if lastName1 > lastName2
                               then GT
                               else if lastName1 < lastName2
                                    then LT
                                    else if firstName1 > firstName2
                                         then GT
                                         else if firstName1 < firstName2
                                              then LT
                                              else EQ
  where lastName1 = snd name1
        lastName2 = snd name2
        firstName1 = fst name1
        firstName2 = fst name2

sortedFull = sortBy compareBothNames names

sfOffice name = if lastName < "L"
                then nameText ++ " - PO Box 1234 - San Francisco, CA 94111"
                else nameText ++ " - PO Box 1010 - San Francisco, CA 94111"
  where lastName = snd name
        nameText = (fst name) ++ " " ++ lastName

nyOffice name = nameText ++ ": PO Box 789 - New York, NY 10013"
  where nameText = (fst name) ++ " " ++ (snd name)
renoOffice name = nameText ++ " - PO Box 456 - Reno, NV 89523"
  where nameText = snd name
washingtonOffice name = nameText ++ " - PO Box 2121 - Washington, DC 20031"
  where nameText = (fst name) ++ " " ++ (snd name) ++ ", Esq"

getLocationFunction location = case location of
  "ny" -> nyOffice
  "sf" -> sfOffice
  "reno" -> renoOffice
  "dc" -> washingtonOffice
  _ -> (\name -> (fst name) ++ " " ++ (snd name))

addressLetter name location = locationFunction name
  where locationFunction = getLocationFunction location

-- Q4.1
-- already done above.  I used compare when I first wrote it

-- Q4.2
-- added above
