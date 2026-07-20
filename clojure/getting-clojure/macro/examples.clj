;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; Macros

(ns user
    (:require [testsupport :refer :all]))

;
(defn print-rating [rating]
  (cond
    (pos? rating)  (println "Good book!")
    (zero? rating) (println "Totally indifferent.")
    :else          (println "Run away!")))
;

;
(defn arithmetic-if [n pos zero neg]
  (cond
    (pos? n) pos
    (zero? n) zero
    (neg? n) neg))
;

;
(arithmetic-if 0 :great :meh :boring)
;

;
(defn print-rating [rating]
  (arithmetic-if rating
    (println "Good book!")
    (println "Totally indifferent.")
    (println "Run away!")))

(print-rating 10)
;

;
(defn arithmetic-if [n pos-f zero-f neg-f]
  (cond
    (pos? n) (pos-f)
    (zero? n) (zero-f)
    (neg? n) (neg-f)))
;

;
(defn print-rating [rating]
  (arithmetic-if rating
    #(println "Good book!")
    #(println "Totally indifferent.")
    #(println "Run away!")))

(print-rating 10)
;

(comment
;
(arithmetic-if rating
  (println "Good book!")
  (println "Totally indifferent.")
  (println "Run away!"))
;
)

(def rating 1)
;
(cond
  (pos? rating)  (println "Good book!")
  (zero? rating) (println "Totally indifferent.")
  :else          (println "Run away!"))
;

;
(defn arithmetic-if->cond [n pos zero neg]
  (list 'cond (list 'pos? n) pos
              (list 'zero? n) zero
              :else neg))
;

;
(arithmetic-if->cond 'rating
  '(println "Good book!")
  '(println "Totally indifferent.")
  '(println "Run away!"))
;

;
(cond
  (pos? rating) (println "Good book!")
  (zero? rating) (println "Totally indifferent.")
  :else (println "Run away!"))
;

;
(defmacro arithmetic-if [n pos zero neg]
  (list 'cond (list 'pos? n) pos
              (list 'zero? n) zero
              :else neg))
;

;
(arithmetic-if rating :loved-it :meh :hated-it)
;

;
(cond (pos? rating) :loved-it (zero? rating) :meh :else :hated-it)
;

;
(defmacro print-it [something]
  (list 'println "Something is" something))
;

;
(print-it (+ 10 20))
;

;
(println "Something is" (+ 10 20))
;

;
(defmacro arithmetic-if [n pos zero neg]
  (list 'cond (list 'pos? n) pos
              (list 'zero? n) zero
              :else neg))
;


(should=
  ;
  ;; Notice the backquote character at the start.

  `(:a :syntax "quoted" :list 1 2 3 4)
  ;

  ;
  '(:a :syntax "quoted" :list 1 2 3 4)
  ;
)

(mdef [_ _ _ _ actual-result]
  ;
  ;; Set up some values.

  (def n 100)
  (def pos "It's positive!")
  (def zero "It's zero!")
  (def neg "It's negative")

  ;; And plug them in the cond.

  `(cond
    (pos? ~n) ~pos
    (zero? ~n) ~zero
    :else ~neg)
  ;
)


;
(cond
  (pos? 100) "It's positive!"
  (zero? 100) "It's zero!"
  :else "It's negative!")
;

(def expected-result (quote
  ;
  (clojure.core/cond
    (clojure.core/pos? 100) "It's positive!"
    (clojure.core/zero? 100) "It's zero!"
    :else "It's negative")
  ;
))

(should= expected-result actual-result)

;
(defmacro arithmetic-if [n pos zero neg]
  `(cond
     (pos? ~n) ~pos
     (zero? ~n) ~zero
     :else ~neg))
;

;
(macroexpand-1 '(arithmetic-if 100 :pos :zero :neg))
;

;
(cond (pos? 100) :pos (zero? 100) :zero :else :neg)
;


;
(defmacro our-defn [name args & body]
  `(def ~name (fn ~args ~body)))
;

(def the-expr (quote
  ;
  (our-defn add2 [a b] (+ a b)))
  ;
)

(def the-result (quote
  ;
  (def add2 (fn [a b] ((+ a b))))
  ;
))

(should=
  (macroexpand-1 the-expr)
  '(def add2 (clojure.core/fn [a b] ((+ a b)))))

;
(defmacro our-defn [name args & body]
  `(def ~name (fn ~args ~@body)))
;

(should-result [_ 4]
  ;
  (our-defn add2 [a b] (+ a b))

  (add2 2 2)            ; Give us 4!
  ;
)


;
(defmacro mark-the-times []
  (println "This is code that runs when the macro is expanded.")
  `(println "This is the generated code."))

;; Expand the macro and you get the 1st println
;; but not the 2nd.

(defn use-the-macro []
  (mark-the-times))

;; Here we will get the second println, which is in the generated
;; code, twice.

(use-the-macro)
(use-the-macro)
;

(should-print #"(?s)^This is the generated.*generated"
  (use-the-macro)
  (use-the-macro))

(should-throw
  ;
  (arithmetic-if 1
    (/ 1 0)
    (/ 0 0)
    (/ -1 0))
  ;
)

;
(defmacro describe-it [it]
  `(let [value# ~it]
    (cond
      (list? value#) :a-list
      (vector? value#) :a-vector
      (number? value#) :a-number
      :else :no-idea)))
;

(comment
;
(map describe-it [10 "a string" [1 2 3]])
;
)

;
(defn describe-it [it]
  (cond
    (list? it) :a-list
    (vector? it) :a-vector
    (number? it) :a-number
    :default :no-idea))
;
