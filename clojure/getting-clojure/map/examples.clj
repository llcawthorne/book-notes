;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; Maps, Keywords and Sets

(ns user
    (:require [testsupport :refer :all]))


;
{"title" "Oliver Twist" "author" "Dickens" "published" 1838}
;

(def result
  ;
  (hash-map "title" "Oliver Twist"
            "author" "Dickens"
            "published" 1838)
  ;
)

(should= (result "published") 1838)


;
(def book {"title" "Oliver Twist"
           "author" "Dickens"
           "published" 1838})
;

(should= 1838
  ;
  (get book "published")    ; Returns 1838.
  ;
)


(should= 1838
  ;
  (book "published")
  ;
)

;
:title
:author
:published
:word-count
:preface&introduction
:chapter-1-and-2
;

(should-print
  "Title: Oliver Twist\nBy: Dickens\nPublished: 1838\n"
  ;
  (def book
    {:title "Oliver Twist" :author "Dickens" :published 1838})

  (println "Title:" (book :title))
  (println "By:" (book :author))
  (println "Published:" (book :published))
  ;
)

(should= "Oliver Twist"
  ;
  (book :title)
  ;
)

(should= "Oliver Twist"
  ;
  (:title book)
  ;
)

(def result
  ;
  (assoc book :page-count 362)
  ;
)

(should= result
  ;
  {:page-count 362
   :title "Oliver Twist"
   :author "Dickens"
   :published 1838}
  ;
)

(def result
  ;
  (assoc book :page-count 362 :title "War & Peace")
  ;
)

(should= 362 (:page-count result))
(should= "War & Peace" (:title result))

(should=  {:title "Oliver Twist" :author "Dickens"}
  ;
  (dissoc book :published)
  ;
)


(should= {}
  ;
  (dissoc book :title :author :published)
  ;
)

(should= book
  ;
  (dissoc book :paperback :illustrator :favorite-zoo-animal)
  ;
)

(def the-keys
  ;
  (keys book)
  ;
)

(defq expected-keys
  ;
  (:title :author :published)
  ;
)

(should= (sort the-keys) (sort expected-keys))


;
(vals book)
;

;
{:title "Oliver Twist", :author "Dickens", :published 1838}
;

;
(def genres #{:sci-fi :romance :mystery})

(def authors #{"Dickens" "Austen" "King"})
;

(should (set? genres))
(should (set? authors))

(should-result [true false]
  ;
  (contains? authors "Austen")    ; => true

  (contains? genres "Austen")     ; => false
  ;
)

(should-result ["Austen" nil]
  ;
  (authors "Austen")    ; => "Austen"

  (genres :historical)  ; => nil
  ;
)

(should-result [:sci-fi nil]
  ;
  (:sci-fi genres)      ; => :sci-fi

  (:historical genres)  ; => nil
  ;
)

;
;; A four element set.

(def more-authors (conj authors "Clarke"))
;

(should (set? more-authors))
(should= (count more-authors) 4)

(def result
  ;
  (conj more-authors "Clarke")
  ;
)

(should= (count result) 4)

(should= #{"Dickens" "Austen" "Clarke"}
  ;
  ;; A set without "King".

  (disj more-authors "King")
  ;
)

(comment
  ;
  (require 'clojure.java.jdbc)

  (def db {:dbtype "derby" :dbname "books"})

  (clojure.java.jdbc/query db ["select * from books"])
  ;
)

(comment
  ;
  (def db {:dbtype "MySQL"
           :dbname "books"
           :user "russ"
           :password "noneofyourbeeswax"})
  ;
)

(should-result [_ nil]
  ;
  (def book
    {:title "Oliver Twist"
     :author "Dickens"
     :published 1838})
  ;
  ;
  (book "title")
  ;
)

(def result
  ;
  (assoc book "title" "Pride and Prejudice")
  ;
)

(should= result
  ;
  {:title "Oliver Twist"
   :author "Dickens"
   :published 1838
   "title" "Pride and Prejudice"}
  ;
)

(should= nil
  ;
  (book :some-key-that-is-clearly-not-there)    ; Gives you nil.
  ;
)

;
(def anonymous-book {:title "The Arabian Nights" :author nil})
;

(should= (:author anonymous-book) nil)

(should-result [true true false]
  ;
  (contains? anonymous-book  :title)            ; True!
  (contains? anonymous-book  :author)           ; Also true!
  (contains? anonymous-book  :favorite-color)   ; False!
  ;
)

(should-result [_ true false true]
  ;
  ;; Our books may be anonymous.

  (def possible-authors #{"Austen" "Dickens" nil})

  (contains? possible-authors  "Austen")         ; True!
  (contains? possible-authors  "King")           ; False!
  (contains? possible-authors  nil)              ; True!
  ;
)

(should-result [_ _ _ 3]
  ;
  (def book {:title "Hard Times"
             :author "Dickens"
             :published 1838})

  (first book) ; Might return [:published 1838].
  (rest book)  ; Maybe ([:title "Hard Times] [:author "Dickens"]).
  (count book) ; Will definitely return 3.
  ;
)
