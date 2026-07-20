;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
(ns sample-generators
  (:require [testsupport :refer :all])
  (:require [clojure.test.check.clojure-test :as ctest])
  (:require [clojure.test.check :as tc])
  (:require [clojure.test.check.generators :as gen])
  (:require [clojure.test.check.properties :as prop]))

(mdef [_ ans]
  ;
  (require '[clojure.test.check.generators :as gen])

  (gen/sample gen/string-alphanumeric)
  ;
)

(should (every? string? ans))
(should= 10 (count ans))


;
(require '[clojure.test.check.clojure-test :as ctest])
(require '[clojure.test.check :as tc])
(require '[clojure.test.check.properties :as prop])
;

;
(prop/for-all [i gen/pos-int]
  (< i (inc i)))
;


(def result
  ;
  (tc/quick-check 50
    (prop/for-all [i gen/pos-int]
      (< i (inc i))))
  ;
)

(should= #{:result :num-tests :seed} (set (keys result)))

;
{:inventory [{:title "S0" :author "po" :copies 2}
             {:title "B2d" :author "fN" :copies 2}]
 :book {:title "S0" :author "po" :copies 2}}
;


;
(require '[clojure.test.check.generators :as gen])

(gen/sample gen/string-alphanumeric)
;

(comment
  ;
  ("" "Q" "h" "q" "7" "ap" "6" "fdKMQ" "KcuWd" "h2O")
  ;
)
