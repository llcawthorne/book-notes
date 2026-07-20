-- file: ch04/Partial.hs
isInAny needle haystack = any inSequence haystack
    where inSequence s = needle `isInfixOf` s

-- now with lambda!
isInAny2 needle haystack = any (\s -> needle `isInfixOf` s) haystack

-- now partially applied function
isInAny3 needle haystack = any (isInfixOf needle) haystack

-- partial applied infix function
isInAny4 needle haystack = any (needle `isInfixOf`) haystack
