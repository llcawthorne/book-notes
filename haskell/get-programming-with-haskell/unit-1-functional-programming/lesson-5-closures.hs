
getIfXEven = (\f x -> if even x then f x else x)

-- order your function arguments from most to least general
getRequestURL host apiKey resource id = 
  host ++ "/" ++ resource ++ "/" ++ id ++ "?token=" ++ apiKey

genHostRequestBuilder host = (\apiKey resource id -> 
                                getRequestURL host apiKey resource id)

genHostRequestBuilder2 host = getRequestURL host

genHostRequestBuilder3 = getRequestURL

exampleUrlBuilder = genHostRequestBuilder "http://example.com"

-- QC 5.2
genApiRequestBuilder hostBuilder apiKey resource = (\id -> hostBuilder apiKey resource id)
-- *Main> exCheck = genApiRequestBuilder exampleUrlBuilder "leetSkidz" "book"
-- *Main> exCheck (show 5)
-- "http://example.com/book/5?token=leetSkidz"

exampleUrlBuilder2 = getRequestURL "http://example.com"

-- QC 5.3
resourcePicker = getRequestURL "http://example.com" "1337hAsk3ll" "book"

-- QC 5.4
subtract2 = flip (-) 2

-- Q5.1
ifEven f x = if even x
             then f x
             else x
inc = (+) 1
double = (*) 2
square = flip (^) 2
ifEvenInc = ifEven inc
ifEvenDouble = ifEven double
ifEvenSquare = ifEven square

-- Q5.2
binaryPartialApplication f x = (\y -> f x y)

