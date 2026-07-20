
-- No error checking; either it matches the pattern or we throw an error
-- just like standard head.
car (x:xs) = x
car _      = error "No car!"
caar (x:y:xs) = y
caar _        = error "No caar!"
caaar (x:y:z:xs) = z
caaar _          = error "No caaar!"
caaaar (x:y:z:zee:xs) = zee
caaaar _              = error "No caaaar!"

cdr (x:xs)  = xs
cdr _       = []
cddr (x:y:xs) = xs
cddr _        = []
cdddr (x:y:z:xs) = xs
cdddr _          = []
cddddr (x:y:z:zee:xs) = xs
cddddr _              = []
