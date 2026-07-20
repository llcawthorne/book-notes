;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
(ns trouble-one
  (:require [testsupport :as ts])
  (:require [clojure.test :refer :all])
  (:require [clojure.test.check.clojure-test :as ctest])
  (:require [clojure.test.check :as tc])
  (:require [clojure.test.check.generators :as gen])
  (:require [clojure.test.check.properties :as prop]))

;
(defn f [a b] (/ a b))
;

(ts/should= 1/2 (f 1 2))
(ts/should= 4 (f 8 2))

;
(deftest test-f
  (is (= 1/2 (f 1 2)))
  (is (= 1/2 (f 3 6)))
  (is (= 1 (f 10 10))))
;

(test-f)

;
(ctest/defspec more-complex-spec 10000
  (prop/for-all [a gen/pos-int
                 b gen/pos-int]
    (is (= (* b (f a b)) a))))
;

(comment (test-f-spec))

;
(defn more-complex-f [a b] (/ a (+ b 863947)))

(ctest/defspec test-more-complex 10000
  (prop/for-all [a gen/pos-int
                 b gen/pos-int]
    (= (* (more-complex-f a b) (- b 863947)) a)))
;

(test-more-complex)
