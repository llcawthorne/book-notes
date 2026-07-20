;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; Namespaces

(ns user
  (:require [testsupport  :refer :all]))

;
(def discount-rate 0.15)
;

;
(ns pricing)
;

(testsupport/should= 'pricing (ns-name *ns*))

;
(ns pricing)

(def discount-rate 0.15)

(defn discount-price [book]
  (* (- 1.0 discount-rate) (:price book)))
;

(testsupport/should (fn? discount-price))

;
(ns user)
;

(testsupport/should= 'user (ns-name *ns*))


;
;; Back to the pricing namespace.

(ns pricing)
;

;
(println (discount-price {:title "Emma" :price 9.99}))
;

(testsupport/should= 'pricing (ns-name *ns*))

;;TBD

;
(ns user)

;; I can get at discount-price in pricing like this!

(println (pricing/discount-price {:title "Emma" :price 9.99}))
;

(should-result [_ [1 2 3]]
  ;
  ;; Make sure we have loaded the code that
  ;; define the clojure.edn namespace.

  (require 'clojure.edn)

  ;; And now we can use clojure.edn to our
  ;; heart's content.

  (clojure.edn/read-string "[1 2 3]")  ;=> [1 2 3]
  ;
)

(comment
  ;
  (require '[blottsbooks.pricing :as pricing])
  ;
)


(comment
  ;
  (ns blottsbooks.core
    (:require [blottsbooks.pricing :as pricing])
    (:gen-class))
  ;
)

(comment
  ;
  (defn -main []
    (println
      (pricing/discount-price {:title "Emma" :price 9.99})))
  ;
)

(comment
  ;
  (require '[blottsbooks.pricing :refer [discount-price]])
  ;
)

(comment
  ;
  ;; Now that I've done the :refer...

  (discount-price {:title "Emma" :price 9.99})
  ;
)

(ns line398)
(ns user)
(ns read-string-demo)

;
(println "Current ns:" *ns*)
;

(ns user)
;
(find-ns 'user)  ; Get the namespace called 'user.
;

;
(ns-map (find-ns 'user))    ; Includes all the predefined vars.
;

;
(ns-map 'user)
;

(testsupport/should= "pricing"
  ;
  ;; Gives us "pricing".

  (namespace 'pricing/discount-print)
  ;
)

(ns blottsbooks.pricing)

(def first-keyword
  ;
  :blottsbooks.pricing/author
  ;
)

(testsupport/should= first-keyword
  ;
  ::author
  ;
)

;
(require '[clojure.core :refer :all])
;

;
(ns-map 'clojure.core)
;

(ns blottsbooks.pricing)
(def discount-rate 0.75)

(ns user)

(defn function-with-side-effects [] 88)

;
;; I really only want this to happen once.

(def some-value (function-with-side-effects))
;

;
;; Just set some-value the first time.

(defonce some-value (function-with-side-effects))
;

(should= some-value 88)
(defonce some-value 444)
(should= some-value 88)

;
(ns-unmap *ns* 'some-value)
;

(defonce some-value 444)
(should= some-value 444)
