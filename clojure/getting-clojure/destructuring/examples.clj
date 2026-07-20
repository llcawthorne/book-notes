;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; Destructuring

(ns user
  (:require [testsupport :refer :all]))


;
(def artists [:monet :austen])
;

(should-print #"(?s)painter.*mon.*novel.*austen"
  ;
  (let [painter (first artists)
        novelist (second artists)]
    (println "The painter is:" painter
             "and the novelist is" novelist))
  ;
)


(should-print #"(?s)painter.*mon.*novel.*austen"
  ;
  (let [[painter novelist] artists]
    (println "The painter is:" painter
             "and the novelist is:" novelist))
  ;
)

;
(def artists [:monet :austen :beethoven :dickinson])
;

(should-print #"(?s)mon.*aus.*bee.*dickinson"
  ;
  (let [[painter novelist composer poet] artists]
    (println "The painter is" painter)
    (println "The novelist is" novelist)
    (println "The composer is" composer)
    (println "The poet is" poet))
  ;
)

(should-print #"(?s)mon.*aus.*bee"
  ;
  (let [[painter novelist composer] artists]
    (println "The painter is" painter)
    (println "The novelist is" novelist)
    (println "The composer is" composer))
  ;
)

(should-print #"(?s)bee.*dickinson"
  ;
  (let [[dummy dummy composer poet] artists]
    (println "The composer is" composer)
    (println "The poet is" poet))
  ;
)

(should-print #"(?s)bee.*dickinson"
  ;
  (let [[_ _ composer poet] artists]
    (println "The composer is" composer)
    (println "The poet is" poet))
  ;
)

;
(def pairs [[:monet :austen] [:beethoven :dickinson]])
;

(should-print #"(?s)mon.*bee"
  ;
  (let [[[painter] [composer]] pairs]
    (println "The painter is" painter)
    (println "The composer is" composer))
  ;
)

(should-print #"(?s)mon.*dickinson"
  ;
  (let [[[painter] [_ poet]] pairs]
    (println "The painter is" painter)
    (println "The poet is" poet))
  ;
)

;
(def artist-list '(:monet :austen :beethoven :dickinson))
;

(should-print #"(?s)mon.*austen.*bee"
  ;
  (let [[painter novelist composer] artist-list]
    (println "The painter is" painter)
    (println "The novelist is" novelist)
    (println "The composer is" composer))
  ;
)

(should-print #"(?s)spell Jane.*J.*a.*n.*e"
  ;
  (let [[c1 c2 c3 c4] "Jane"]
    (println "How do you spell Jane?")
    (println c1)
    (println c2)
    (println c3)
    (println c4))
  ;
)

;
(defn artist-description [[novelist poet]]
  (str "The novelist is " novelist " and the poet is " poet))
;

(should-match #"novelist.*:austen.*poet.*:dickinson"
  ;
  (artist-description [:austen :dickinson])
  ;
)

;
(defn artist-description [shout [novelist poet]]
  (let [msg (str "Novelist is " novelist
                 "and the poet is " poet)]
    (if shout (.toUpperCase msg) msg)))
;

(should-match
  #"(?s)NOVEL.*AAA.*POET.*BBB"
  (artist-description true ["Aaa" "Bbb"]))

(should-match
  #"(?s)Novel.*Aaa.*poet.*Bbb"
  (artist-description false ["Aaa" "Bbb"]))


;
(def artist-map {:painter :monet  :novelist :austen})
;

(should-print #"(?s)painter is :monet.*:austen"
  ;
  (let [{painter :painter writer :novelist} artist-map]
    (println "The painter is" painter)
    (println "The novelist is" writer))
  ;
)

(should-print #"(?s)painter is :monet.*:austen"
  ;
  (let [{writer :novelist painter :painter} artist-map]
    (println "The painter is" painter)
    (println "The novelist is" writer))
  ;
)

;
(def austen {:name "Jane Austen"
             :parents {:father "George" :mother "Cassandra"}
             :dates {:born 1775 :died  1817}})
;

(should-print #"(?s).*dad.*George.*mom.*Cassandra"
  ;
  (let [{{dad :father mom :mother} :parents} austen]
    (println "Jane Austen's dad's name was" dad)
    (println "Jane Austen's mom's name was" mom))
  ;
)

(comment
;
(let [<<something-to-bind-to>> austen]
  ;; Do something with the data...
  )
;
)

(comment
;
(let [{<<something-to-bind-parents-to>> :parents} austen]
  ;; Do something with the data...
  )
;
)

;
(let [{{dad :father mom :mother} :parents} austen]
  ;; Do something with the data...
  )
;

(should-print #"(?s)born.*1775.*mother.*Cassandra"
  ;
  (let [{name :name
         {mom :mother} :parents
         {dob :born} :dates} austen]
    (println name "was born in" dob)
    (println name "mother's name was" mom))
  ;
)

;
(def author {:name "Jane Austen"
             :books [{:title "Sense and Sensibility" :published 1811}
                     {:title "Emma" :published 1815}]})
;

(should-print #"(?s).*Jane.*Emma"
  ;
  (let [{name :name [_ book] :books} author]
    (println "The author is" name)
    (println "One of the author's books is" book))
  ;
)

;
(def authors  [{:name "Jane Austen" :born 1775}
               {:name "Charles Dickens" :born 1812}])
;

(should-print #"(?s)One.*1775.*other.*1812"
  ;
  (let [[{dob-1 :born} {dob-2 :born}] authors]
    (println "One author was born in" dob-1)
    (println "The other author was born in" dob-2))
  ;
)

(def the-romeo
  ;
  {:name "Romeo" :age 16 :gender :male}
  ;
)

;
(defn character-desc [{name :name age :age gender :gender}]
  (str "Name: " name " age: " age " gender: " gender))
;

(should= (character-desc the-romeo) "Name: Romeo age: 16 gender: :male")

;
(defn character-desc [{:keys [name age gender]}]
  (str "Name: " name " age: " age " gender: " gender))
;

(should= (character-desc the-romeo) "Name: Romeo age: 16 gender: :male")

;
(defn character-desc [{:keys [name gender] age-in-years :age}]
  (str "Name: " name " age: " age-in-years " gender: " gender))
;

(should= (character-desc the-romeo) "Name: Romeo age: 16 gender: :male")

;
(defn add-greeting [character]
  (let [{:keys [name age]} character]
    (assoc character
           :greeting
           (str "Hello, my name is " name " and I am " age "."))))
;

(should=
  (add-greeting {:name "a" :age 1 :gender :m})
  {:name "a" :age 1 :gender :m :greeting "Hello, my name is a and I am 1."})

;
(defn add-greeting [{:keys [name age] :as character}]
  (assoc character
         :greeting
         (str "Hello, my name is " name " and I am " age ".")))
;

(should=
   (add-greeting {:name "a" :age 1 :gender :m})
   {:name "a" :age 1 :gender :m :greeting "Hello, my name is a and I am 1."})

(def the-readers
  ;
  [{:name "Charlie",  :fav-book {:title "Carrie", :author ["Stephen" "King"]}}
   {:name "Jennifer", :fav-book {:title "Emma", :author ["Jane" "Austen"]}}]
  ;
)

;
(defn format-a-name [[_ {{[fname lname] :author} :fav-book}]]
  (str fname " " lname))
;

(assert= "Jane Austen" (format-a-name the-readers))

;
(defn format-a-name [[_ second-reader]]
  (let [author (-> second-reader :fav-book :author)]
    (str (first author) " " (second author))))
;

(assert= "Jane Austen" (format-a-name the-readers))

(comment
  ;
  ;; No!!

  (def author {:name "Jane Austen" :born 1775})

  (def author-name [{n :name} author])
  ;
)

;
(def author-name
  (let [{n :name} author] n))
;

(should= "Jane Austen" author-name)

;
(defn mysql
"Create a database specification for a
 mysql database. Opts should include
 keys for :db, :user, and :password.
 You can also optionally set host and port.
 Delimiters are automatically set to \"`\"."
  [{:keys [host port db make-pool?]
    :or {host "localhost", port 3306, db "", make-pool? true}
    :as opts}]

    ;; Do something with host, port, db, make-pool? and opts
)
;
