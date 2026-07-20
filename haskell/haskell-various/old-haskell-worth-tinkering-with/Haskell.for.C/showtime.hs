#!/usr/bin/env runhaskell
-- showTime function formats two Int's as a time string "hh:mm am"
showTime :: Int -> Int -> String
showTime hours minutes
    -- first get errors out of the way:
    | hours > 23 || hours < 0 || minutes < 0 || minutes > 59
    = error "Invalid input to showTime!"
    -- now determine how to format the string:
    | hours == 0    = "12" ++ ":" ++ showMin ++ " am"
    | hours <= 11   = (show hours) ++ ":" ++ showMin ++ " am"
    | hours == 12   = (show hours) ++ ":" ++ showMin ++ " pm"
    | otherwise     = (show (hours -12)) ++ ":" ++ showMin ++ " pm"
    where
    showMin | minutes < 10  = "0" ++ show minutes
            | otherwise     =        show minutes
