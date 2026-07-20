;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
(ns blottsbooks.pricing)

(def discount-rate 0.15)

(defn  compute-discount-price [book]
  (- (:price book)
     (* discount-rate (:price book))))
