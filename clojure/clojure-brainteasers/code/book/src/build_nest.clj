;---
; Excerpted from "Clojure Brain Teasers",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/mmclobrain for more book information.
;---
(def ex1
  (for [a [0 1 2]
        b [3 4 5]]
     (* a b)))

(def ex2
  (for [a [0 1 2]]
    (for [b [3 4 5]]
      (* a b))))
     
(= ex1 ex2)