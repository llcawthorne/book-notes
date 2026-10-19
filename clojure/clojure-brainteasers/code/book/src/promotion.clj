;---
; Excerpted from "Clojure Brain Teasers",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/mmclobrain for more book information.
;---
(def bignum    9223372036854775807)
(def biggernum 9223372036854775808)

(= biggernum (+ bignum 1))
(= biggernum (+' bignum 1))
(= biggernum (unchecked-add bignum 1))
