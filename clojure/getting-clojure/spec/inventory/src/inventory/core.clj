;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;
(ns inventory.core
  (:require [clojure.spec.alpha :as s]))
;

(require '[testsupport :refer :all])

(def example-book
  ;
  {:title "Getting Clojure" :author "Olsen" :copies 1000000}
  ;
)

;
(defn book? [x]
  (and
    (map? x)
    (string? (:author x))
    (string? (:title x))
    (pos-int? (:copies x))))
;

(should (book? example-book))

(should-result [true false]
  ;
  (s/valid? number? 44)     ; Returns true.
  (s/valid? number? :hello) ; Returns false.
  ;
)

(should-result [_ false false true]
  ;
  (def n-gt-10 (s/and number? #(> % 10)))

  (s/valid? n-gt-10 1)   ; Nope.
  (s/valid? n-gt-10 10)  ; Still nope.
  (s/valid? n-gt-10 11)  ; True.
  ;
)

;
(def n-gt-10-lt-100
  (s/and number? #(> % 10) #(< % 100)))
;

(should-result [_ true true false]
  ;
  (def n-or-s (s/or :a-number number? :a-string string?))

  (s/valid? n-or-s "Hello!")  ; Yes!
  (s/valid? n-or-s 99)        ; Yes!
  (s/valid? n-or-s  'foo)     ; No, it's a symbol.
  ;
)


(should (s/valid? n-gt-10-lt-100 11))
(should (s/valid? n-gt-10-lt-100 99))
(should (not (s/valid? n-gt-10-lt-100 9)))
(should (not (s/valid? n-gt-10-lt-100 10)))
(should (not (s/valid? n-gt-10-lt-100 100)))
(should (not (s/valid? n-gt-10-lt-100 101)))


;
(def n-gt-10-or-s (s/or :greater-10 n-gt-10 :a-symbol symbol?))
;

;
;; Something like '("Alice" "In" "Wonderland").

(def coll-of-strings (s/coll-of string?))

;; Or a collection of numbers or strings, perhaps ["Emma" 1815 "Jaws" 1974]

(def coll-of-n-or-s (s/coll-of n-or-s))
;

(should (s/valid? coll-of-strings ["a" "b"]))
(should (not (s/valid? coll-of-strings ["a" 1 "b"])))

(should (s/valid? coll-of-n-or-s ["a" "b"]))
(should (s/valid? coll-of-n-or-s ["a" 111 "b"]))
(should (not (s/valid? coll-of-n-or-s ["a" :fooo 111 "b"])))


(should-result [_ true]
  ;
  (def s-n-s-n (s/cat :s1 string? :n1 number? :s2 string? :n2 number?))

  (s/valid? s-n-s-n ["Emma" 1815 "Jaws" 1974])   ; Yes!
  ;
)

;
(def book-s
  (s/keys :req-un [:inventory.core/title
                   :inventory.core/author
                   :inventory.core/copies]))
;

(should-result [true false true]
  ;
  ;; Yes!

  (s/valid? book-s {:title "Emma" :author "Austen" :copies 10})

  ;; No! :author missing.

  (s/valid? book-s {:title "Arabian Nights" :copies 17})

  ;; Yes! Additional entries are OK:

  (s/valid? book-s {:title "2001" :author "Clarke" :copies 1 :published 1968})
  ;
)

;
(s/def
  :inventory.core/book
  (s/keys
    :req-un
    [:inventory.core/title :inventory.core/author :inventory.core/copies]))
;


(should-result [true]
  ;
  ;; Validate a book against the registered spec.

  (s/valid? :inventory.core/book {:title "Dracula" :author "Stoker" :copies 10})
  ;
)

(s/explain :inventory.core/book {:title 1234 :author false :copies "many"})

(should (s/valid? :inventory.core/book
  ;
  {:title 1234 :author false :copies "many"}
  ;
))


;
(s/def ::book (s/keys :req-un [::title ::author ::copies]))
;


;
(s/def ::title string?)

(s/def ::author string?)

(s/def ::copies int?)

(s/def ::book (s/keys :req-un [::title ::author ::copies]))
;

(should (not (s/valid? ::book
  {:title 1234 :author false :copies "many"}
)))

(should-result [_ false]
  ;
  (s/valid? ::book {:author :austen :title :emma})
  ;
)

(should-print #"Success"
  ;
  (s/explain n-gt-10 44)
  ;
)

(should-print #"fails"
  ;
  (s/explain n-gt-10 1)
  ;
)

(should-print #":austen.*fails"
  ;
  (s/explain ::book {:author :austen :title :emma})
  ;
)

;
(s/conform s-n-s-n ["Emma" 1815 "Jaws" 1974])
;

;
(s/conform number? 1968)
;

(def result
  ;
  {:s1 "Emma", :n1 1815, :s2 "Jaws", :n2 1974}
  ;
)


(should= result
  ;
  (s/conform s-n-s-n ["Emma" 1815 "Jaws" 1974])
  ;
)

;
;; Register a handy spec: An inventory is a collection of books.

(s/def :inventory.core/inventory
  (s/coll-of ::book))


(defn find-by-title
  [title inventory]
  {:pre [(s/valid? ::title title)
         (s/valid? ::inventory inventory)]}
  (some #(when (= (:title %) title) %) inventory))
;


;
;; Define the function.

(defn find-by-title
  [title inventory]
  (some #(when (= (:title %) title) %) inventory))

;; Register a spec for the find-by-title function.

(s/fdef find-by-title
   :args (s/cat :title ::title
                :inventory ::inventory))
;

;
(require '[clojure.spec.test.alpha :as st])
;

;
(st/instrument 'inventory.core/find-by-title)
;

(should (find-by-title "Getting Clojure" [example-book]))
(should-throw (find-by-title 33 33))

(should-throw
  ;
  (find-by-title "Emma" ["Emma" "2001" "Jaws"])
  ;
)

;
(s/def ::author string?)

(s/def ::title string?)

(s/def ::copies pos-int?)

(s/def ::book (s/keys :req-un [::title ::author ::copies]))

(s/fdef find-by-title
   :args (s/cat :title ::title :inventory ::inventory))

(st/instrument `find-by-title)
;

;
(defn book-blurb [book]
  (str "The best selling book " (:title book) " by " (:author book)))

(s/fdef book-blurb :args (s/cat :book ::book))
;

;
(require '[clojure.spec.test.alpha :as stest])

(stest/check 'inventory.core/book-blurb)
;

;
(s/fdef book-blurb
  :args (s/cat :book ::book)
  :ret (s/and string? (partial re-find #"The best selling")))
;

(should (stest/check 'inventory.core/book-blurb))

;
(defn check-return [{:keys [args ret]}]
  (let [author (-> args :book :author)]
    (not (neg? (.indexOf ret author)))))

(s/fdef book-blurb
  :args (s/cat :book ::book)
  :ret (s/and string? (partial re-find #"The best selling"))
  :fn check-return)
;

(should (stest/check 'inventory.core/book-blurb))

;
(s/def ::author string?)

(s/def ::titlo string?)

(s/def ::copies pos-int?)

(s/def ::book
       (s/keys :req-un [::title ::author ::copies]))

;; Register a spec for the find-by-title function.

(s/fdef find-by-title
  :args (s/cat :title ::title
               :inventory ::inventory))
;

(defn -main []
  (println "dummy main program")
  (System/exit 0))
