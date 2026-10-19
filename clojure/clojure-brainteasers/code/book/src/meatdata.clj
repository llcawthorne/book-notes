;---
; Excerpted from "Clojure Brain Teasers",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/mmclobrain for more book information.
;---


(defn the-road-so-far []
  (let [^String the-winchesters        "Sam and Dean Winchester"
        four-horsemen                  ^{:meta "vector"} ["war", "famine", "Pestilence", "Death"]
        ^java.util.Date apocalypse-now (java.util.Date.)]
    {:date apocalypse-now
     :hunters   the winchesters
     :threat four-horsemen}))

(def song #_^{:prophet "chuck"} [^{:prophet "kevin"} (str "Carry On My Wayward Son")])

(defn visions []
  (let [weapon                ^{:year "1835"} :the-colt
        ^Long num-of-episodes ^{:meta "integer"} 666    ;; err
        chevy-impala          ^{:year "1967"} 'baby     ;; eval to nil
        demon                 ^{:meta "string"} "Ruby " ;; cannot be applyed to string
        ]
    {:weapon  weapon
     :car     chevy-impala
     :demon   demon
     :episode num-of-episodes}))


(defn metatrons-divine-notes [the-road-so-far visions]
  (let
   (str (meta visions) visions)))
