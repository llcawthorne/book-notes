;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;
(ns inventory.core-test
  (:require [clojure.test :refer :all])
  (:require [inventory.core :as i]))
;

;
(def books
  ;
  [{:title "2001"   :author "Clarke" :copies 21}
   {:title "Emma"   :author "Austen" :copies 10}
   {:title "Misery" :author "King"   :copies 101}])
;

;
(deftest test-finding-books
  (is (not (nil? (i/find-by-title "Emma" books)))))
;
;

;
(require '[inventory.core :as i])

(deftest test-finding-books
  (is (not (nil? (i/find-by-title "Emma" books)))))
;

;
(deftest test-finding-books-better
  (is (not (nil? (i/find-by-title "Emma" books))))
  (is (nil? (i/find-by-title "XYZZY" books))))
;

;
(deftest test-basic-inventory
  (testing "Finding books"
    (is (not (nil? (i/find-by-title "Emma" books))))
    (is (nil? (i/find-by-title "XYZZY" books))))
  (testing "Copies in inventory"
    (is (= 10 (i/number-of-copies-of "Emma" books)))))
;

(defn book? [x]
  (and
    (map? x)
    (string? (:title x))
    (string? (:author x))
    (number? (:copies x))))

  ;
  (deftest test-do-we-really-find-a-book
    (is (book? (i/find-by-title "Emma" books))))
  ;
