-- Exercises.hs
module Exercises where

mult = x * 3 + y
 where x = 3
       y = 1000

mult2 = x * 5
 where y = 10
       x = 10 * 5 + y

divvie = z / x + y
 where x = 7
       y = negate x
       z = y * 10

z = 7
y = z + 8
x = y ^ 2

waxOn = x * 5

triple x = x * 3

waxOff x = triple x
