;---
; Excerpted from "Clojure Brain Teasers",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/mmclobrain for more book information.
;---
(defn doubled 
  "Returns a sequence of all i's from 0 to n (exclusive), doubled.
  Ex: (doubled 3)  ;; (0 0 1 1 2 2)"
  [n]
  (loop [i 0
         output ()]
    (if (< i n)
      (recur (inc i) 
             (concat output [i i]))
      output)))

(= 0 (first (doubled 50000)))
