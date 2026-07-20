;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
(ns trouble-two
  (:require [testsupport :as ts])
  (:require [clojure.test :refer :all])
  (:require [clojure.test.check.clojure-test :as ctest])
  (:require [clojure.test.check :as tc])
  (:require [clojure.test.check.generators :as gen])
  (:require [clojure.test.check.properties :as prop]))

;
;; Prevent the division by zero.

(defn  more-complex-f [a b]
  (let [denominator (- b 863947)]
    (if (zero? denominator)
      :no-result
      (/ a denominator))))

;; But we still want to be sure we detect it correctly.

(deftest test-critical-value
  (is (= :no-result (more-complex-f 1 863947))))

;; And the function works in other cases.

(def non-critical-gen (gen/such-that (partial not= 863947) gen/pos-int))

(ctest/defspec test-other-values 10000
  (prop/for-all [a gen/pos-int
                 b non-critical-gen]
    (= (* (more-complex-f a b) (- b 863947)) a)))
;

(run-tests)
