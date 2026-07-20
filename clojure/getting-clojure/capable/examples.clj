;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; More Capable Functions

(ns user
    (:require [testsupport :refer :all]))

;
(defn greet
  ([to-whom] (println "Welcome to Blotts Books" to-whom))
  ([message to-whom] (println message to-whom)))
;

(should-print "Welcome to Blotts Books Dolly\n"
  ;
  (greet "Dolly")            ; Welcomes Dolly to Blotts Books.
  ;
)

(should-print "Howdy Stranger\n"
  ;
  (greet "Howdy" "Stranger") ; Prints Howdy Stranger.
  ;
)

;
(defn greet
  ([to-whom] (greet "Welcome to Blotts Books" to-whom))
  ([message to-whom] (println message to-whom)))
;

(should-print "Welcome to Blotts Books Dolly\n" (greet "Dolly"))
(should-print "AA BB\n" (greet "AA" "BB"))

;
(defn print-any-args [& args]
  (println "My arguments are:" args))
;

(should-print "My arguments are: (7 true nil)\n"
  ;
  (print-any-args 7 true nil)
  ;
)

;
(defn first-argument [& args]
  (first args))
;

(should= (first-argument 1 2 3) 1)

;
(defn new-first-argument [x & args] x)
;

(should= (new-first-argument 1 2 3) 1)

(def b1
  ;
  {:title "War and Peace" :author "Tolstoy"}
  ;
)

(def b2
  ;
  {:book "Emma" :by "Austen"}
  ;
)

(def b3
  ;
  ["1984" "Orwell"]
  ;
)

;
;; Normalize book data to {:title ? :author ?}

(defn normalize-book [book]
  (if (vector? book)
    {:title (first book) :author (second book)}
    (if (contains? book :title)
      book
      {:title (:book book) :author (:by book)})))
;

(should= (normalize-book b1) b1)
(should= (normalize-book b2) {:title "Emma" :author "Austen"})
(should= (normalize-book b3) {:title "1984" :author  "Orwell"})

;
(defn dispatch-book-format [book]
  (cond
    (vector? book) :vector-book
    (contains? book :title) :standard-map
    (contains? book :book) :alternative-map))
;

(should= :standard-map (dispatch-book-format b1))
(should= :alternative-map (dispatch-book-format b2))
(should= :vector-book (dispatch-book-format b3))

;
(defmulti normalize-book dispatch-book-format)
;

;
(defmethod normalize-book :vector-book [book]
  {:title (first book) :author (second book)})

(defmethod normalize-book :standard-map [book]
  book)

(defmethod normalize-book :alternative-map [book]
  {:title (:book book) :author (:by book)})
;

(should-result
  [{:title "War and Peace" :author "Tolstoy"}
   {:title "Emma" :author "Austen"}
   {:title "1984" :author "Orwell"}]

  ;
  ;; Just returns the same (standard) book map.

  (normalize-book {:title "War and Peace" :author "Tolstoy"})

  ;; Returns {:title "Emma" :author "Austen"}

  (normalize-book {:book "Emma" :by "Austen"})

  ;; Returns {:title "1984" :author "Orwell"}

  (normalize-book ["1984" "Orwell"])
  ;
)

;
(defn dispatch-published [book]
  (cond
    (< (:published book) 1928) :public-domain
    (< (:published book) 1978) :old-copyright
    :else :new-copyright))

(defmulti compute-royalties dispatch-published)

(defmethod compute-royalties :public-domain [book] 0)

(defmethod compute-royalties :old-copyright [book]
  ;; Compute royalties based on old copyright law.
  )

(defmethod compute-royalties :new-copyright [book]
  ;; Compute royalties based on new copyright law.
  )
;

(should= :public-domain (dispatch-published {:published 1927}))
(should= :old-copyright (dispatch-published {:published 1977}))
(should= :new-copyright (dispatch-published {:published 2001}))


;
(def books [{:title "Pride and Prejudice" :author "Austen" :genre :romance}
            {:title "World War Z" :author "Brooks" :genre :zombie}])
;

;
;; Remember you can use keys like :genre like functions on maps.

(defmulti book-description :genre)

(defmethod book-description :romance [book]
  (str "The heart warming new romance by " (:author book)))

(defmethod book-description :zombie [book]
  (str "The heart consuming new zombie adventure by " (:author book)))
;

(should-match #".*warming.*Austen" (book-description (first books)))
(should-match #".*consuming.*Brooks" (book-description (second books)))

;
(def ppz {:title "Pride and Prejudice and Zombies"
          :author "Grahame-Smith"
          :genre :zombie-romance})
;

;
(defmethod book-description :zombie-romance [book]
  (str "The heart warming and consuming new romance by " (:author book)))
;

(should-match #".*consuming.*Smith" (book-description ppz))

;
(def books
  [{:title "Jaws"  :copies-sold 2000000}
   {:title "Emma"  :copies-sold 3000000}
   {:title "2001"  :copies-sold 4000000}])
;

;
(defn sum-copies
  ([books] (sum-copies books 0))
  ([books total]
    (if (empty? books)
      total
      (sum-copies
        (rest books)
        (+ total (:copies-sold (first books)))))))
;

(should= 9000000 (sum-copies books))

;
(defn sum-copies
  ([books] (sum-copies books 0))
  ([books total]
    (if (empty? books)
      total
      (recur
        (rest books)
        (+ total (:copies-sold (first books)))))))
;

(should= 9000000 (sum-copies books))
(should= 10 (sum-copies [{:copies-sold 4} {:copies-sold 6}]))

;
(defn sum-copies [books]
  (loop [books books total 0]
    (if (empty? books)
      total
      (recur
        (rest books)
        (+ total (:copies-sold (first books)))))))
;

(should= 9000000 (sum-copies books))
(should= 10 (sum-copies [{:copies-sold 4} {:copies-sold 6}]))

;
(defn sum-copies [books] (apply + (map :copies-sold books)))
;

(should= 9000000 (sum-copies books))
(should= 10 (sum-copies [{:copies-sold 4} {:copies-sold 6}]))


;
;; Return the average of the two parameters.
(defn average [a b]
  (/ (+ a b) 2.0))
;

(should= 3.0 (average 2 4))

;
(defn average
  "Return the average of a and b."
  [a b]
  (/ (+ a b) 2.0))
;

(should= 3.0 (average 2 4))

;; Example 25 deleted.

;
(defn multi-average
  "Return the average of 2 or 3 numbers."
  ([a b]
   (/ (+ a b ) 2.0))
  ([a b c]
   (/ (+ a b c) 3.0)))
;

(defn print-book [b] b)

(def ^:dynamic *shipped-value* "Value returned by ship-book" true)

(defn ship-book [b] *shipped-value*)

;
;; Publish a book using the (unseen) print-book
;; and ship-book functions.

(defn publish-book [book]
  (when-not (contains? book :title)
    (throw (ex-info "Books must contain :title" {:book book})))
  (print-book book)
  (ship-book book))
;

(should-throw (publish-book {}))
(should= true (publish-book {:title "Emma"}))

;
(defn publish-book [book]
  {:pre [(:title book)]}
  (print-book book)
  (ship-book book))
;

(should-throw (publish-book {}))
(should= true (publish-book {:title "Emma"}))

;
(defn publish-book [book]
  {:pre [(:title book) (:author book)]}
  (print-book book)
  (ship-book book))
;

(should-throw (publish-book {}))
(should-throw (publish-book {:title "Emma"}))
(should= true (publish-book {:title "Emma" :author "Austen"}))


;
(defn publish-book [book]
  {:pre  [(:title book) (:author book)]
   :post [(boolean? %)]}
  (print-book book)
  (ship-book book))
;

(should-throw (publish-book {}))
(should-throw (publish-book {:title "Emma"}))
(should= true (publish-book {:title "Emma" :author "Austen"}))

(binding [*shipped-value* 44444]
  (should-throw (publish-book {:title "Emma" :author "Austen"})))


;
(defn one-two-or-more
  ([a] (println "One arg:" a))
  ([a b] (println "Two args:" a b))
  ([a b & more] (println "More than two:" a b more)))
;

(should-print #"One" (one-two-or-more 1))
(should-print #"Two" (one-two-or-more 1 2))
(should-print #"More" (one-two-or-more 1 2 3))
(should-print #"More" (one-two-or-more 1 2 3 4))

(comment
  ;
  ;; Oh no!

  (defn one-two-or-more
    ([a] (println "One arg:" a))
    ([a b] (println "Two args:" a b))
    ([& more] (println "More than two:" more)))
  ;
)

;
(defn chatty-average
  ([a b]
    (println "chatty-average function called with 2 arguments")
    (println "** first argument:" a)
    (println "** second argument:" b)
    (/ (+ a b) 2.0)))
;

(should= 3.0 (chatty-average 2 4))

;
(defn chatty-multi-average
  ([a b]
    (println "chatty-average function called with 2 arguments")
    (/ (+ a b) 2.0))
  ([a b c]
    (println "chatty-average function called with 3 arguments")
    (/ (+ a b c) 3.0)))
;

(should= 3.0 (chatty-multi-average 2 4))
(should= 4.0 (chatty-multi-average 3 4 5))


;
(defn print-any-args [& args]
  (println "My arguments are:" args))
;

(should-print #"My.*1 2" (print-any-args 1 2))

(comment
  ;
  (defn print-any-args [&args]
    (println "My arguments are:" args))
  ;
)

;; The following code is derived from the Clojure source.

(comment
  ;
  ;; Code edited a bit for clarity.

  (defn =
    "Equality. Returns true if x equals y, false if not. Same as
    Java x.equals(y) except it also works for nil, and compares
    numbers and collections in a type-independent manner.
    Clojure's immutable data structures define equals()
    (and thus =) as a value, not an identity, comparison."
    ([x] true)
    ([x y] (clojure.lang.Util/equiv x y))
    ([x y & more]
     (if (clojure.lang.Util/equiv x y)
       (if (next more)
         (recur y (first more) (next more))
         (clojure.lang.Util/equiv y (first more)))
       false)))
  ;
)

(comment
  ;
  (defmulti to-url class)

  (defmethod to-url File [f] (.toURL (.toURI f)))

  (defmethod to-url URL [url] url)

  (defmethod to-url String [s] (to-url (io/file s)))
;
)
