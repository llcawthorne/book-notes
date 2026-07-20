;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;
(ns inventory.core-gen-test
  (:require [inventory.core :as i])
  (:require [clojure.test.check.clojure-test :as ctest])
  (:require [clojure.test.check :as tc])
  (:require [clojure.test.check.generators :as gen])
  (:require [clojure.test.check.properties :as prop]))
;

;
(def title-gen gen/string-alphanumeric)

(def author-gen gen/string-alphanumeric)

(def copies-gen gen/pos-int)
;

(def title-gen (gen/such-that not-empty gen/string-alphanumeric))

(def author-gen (gen/such-that not-empty gen/string-alphanumeric))

(def copies-gen (gen/such-that (complement zero?) gen/pos-int))
;

;
(def book-gen
  (gen/hash-map :title title-gen :author author-gen :copies copies-gen))
;

;
(def inventory-gen (gen/not-empty (gen/vector book-gen)))
;

(assert (= 1000 (count
  (gen/sample inventory-gen 1000)
  ;
)))

;
(def inventory-and-book-gen
  (gen/let [inventory inventory-gen
            book (gen/elements inventory)]
     {:inventory inventory  :book book}))
;

(println (gen/sample inventory-and-book-gen))

;
(tc/quick-check 50
  (prop/for-all [i-and-b inventory-and-book-gen]
    (= (i/find-by-title (-> i-and-b :book :title) (:inventory i-and-b))
       (:book i-and-b))))
;

;
(ctest/defspec find-by-title-finds-books 50
  (prop/for-all [i-and-b inventory-and-book-gen]
    (= (i/find-by-title (-> i-and-b :book :title) (:inventory i-and-b))
       (:book i-and-b))))
;
