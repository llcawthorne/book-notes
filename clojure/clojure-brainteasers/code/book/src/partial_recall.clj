;---
; Excerpted from "Clojure Brain Teasers",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/mmclobrain for more book information.
;---
(defn sentence [subject object]
  (str "Is " subject " a " object "?"))

(def planet "Mars")

(def f1 (partial sentence planet))
(def f2 (fn [object] (sentence planet object)))

;; redefine
(def planet "Earth")

(= (f1 "dream") (f2 "dream"))