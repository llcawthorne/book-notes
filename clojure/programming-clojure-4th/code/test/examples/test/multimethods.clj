;---
; Excerpted from "Programming Clojure, Fourth Edition",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/shcloj4 for more book information.
;---
(ns examples.test.multimethods
  (:require
    [clojure.test :refer :all]
    [examples.multimethods :refer :all :as mm]))

(deftest test-my-println 
  (is (= (with-out-str (my-println "foo")) "foo\n")))

(deftest test-my-print
  (let [my-print-str (fn [& args] (with-out-str (apply my-print args)))]
    (are [x y] (= x y)
     (my-print-str "strval") "strval"
     (my-print-str nil) "nil"
     (my-print-str 42) "42"
     (my-print-str '(1 2 3)) "(1 2 3)"
     (my-print-str [4 5 6]) "[4 5 6]"
     (my-print-str (java.io.File. "foo")) "#<foo>")))

(deftest test-my-class
  (are [x y] (= x y)
   String (my-class "foo")
   nil (my-class nil)))

(deftest test-interest-rate
  (are [x y] (= x y)
    (interest-rate {:tag ::mm/checking}) 0M
    (interest-rate {:tag ::mm/savings}) 0.05M))

(deftest test-account-level
  (are [x y] (= x y)
    (account-level {:tag ::mm/checking, :balance 4999}) ::mm/basic
    (account-level {:tag ::mm/checking, :balance 5000}) ::mm/premium
    (account-level {:tag ::mm/savings, :balance 999}) ::mm/basic
    (account-level {:tag ::mm/savings, :balance 1000}) ::mm/premium))

(deftest test-service-charge2
  (are [x y] (= x y)
    (service-charge2 {:tag ::mm/checking, :balance 4999}) 25
    (service-charge2 {:tag ::mm/checking, :balance 5000}) 0
    (service-charge2 {:tag ::mm/savings, :balance 999}) 10
    (service-charge2 {:tag ::mm/savings, :balance 1000}) 0))

(deftest test-service-charge3
  (are [x y] (= x y)
    (service-charge3 {:tag ::mm/checking, :balance 4999}) 25
    (service-charge3 {:tag ::mm/checking, :balance 5000}) 0
    (service-charge3 {:tag ::mm/savings, :balance 999}) 10
    (service-charge3 {:tag ::mm/savings, :balance 1000}) 0))

(comment
  (defn dis [acct] [(account-level acct) (:tag acct)])
  (service-charge2 {:tag ::mm/checking, :balance 4999})

  (run-tests)
  )

  
