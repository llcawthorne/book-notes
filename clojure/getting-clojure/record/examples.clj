;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; Records and Protocols

(ns user
  (:require [testsupport :refer :all]))


(defn get-watson-1 [])
(defn get-watson-2 [])
;
  (let [watson-1 (get-watson-1)
        watson-2 (get-watson-2)]
        ;; Do something with our watsons...
        )
;

;
;; A fictional character.

(defn get-watson-1 []
  {:name "John Watson"
   :appears-in "Sign of the Four"
   :author "Doyle"})

;; A Jeopardy playing computer.

(defn get-watson-2 [] {:cpu "Power7" :no-cpus 2880 :storage-gb 4000})
;

(should= (:author (get-watson-1)) "Doyle")
(should= (:cpu (get-watson-2)) "Power7")

;
(defrecord FictionalCharacter[name appears-in author])
;

;
(def watson (->FictionalCharacter "John Watson" "Sign of the Four" "Doyle"))
;

;
(def watson (FictionalCharacter. "John Watson" "Sign of the Four" "Doyle"))
;

;
(def elizabeth (map->FictionalCharacter
                  {:name "Elizabeth Bennet"
                   :appears-in "Pride & Prejudice"
                   :author "Austen"}))
;

(should-result ["Elizabeth Bennet" "Sign of the Four"]
  ;
  (:name elizabeth)     ; => "Elizabeth Bennet"
  (:appears-in watson)  ; => "Sign of the Four"
  ;
)

(should-result [3 '(:name :appears-in :author)]
  ;
  (count elizabeth)     ; => 3
  (keys watson)         ; => (:name :appears-in :author)
  ;
)

;
(def specific-watson (assoc watson :appears-in "Sign of the Four"))
;

;
(def more-about-watson (assoc watson :address "221B Baker Street"))
;

;
(def irene {:name "Irene Adler"
            :appears-in "A Scandal in Bohemia"
            :author "Doyle"})
;

(should-result ["John Watson" "Irene Adler"]
  ;
  (:name watson)
  ;

  ;
  (:name irene)
  ;
)

;
;; Define the record types.

(defrecord FictionalCharacter[name appears-in author])
(defrecord SuperComputer [cpu no-cpus storage-gb])

;; And create some records.

(def watson-1 (->FictionalCharacter
                "John Watson"
                "Sign of the Four"
                "Doyle"))

(def watson-2 (->SuperComputer "Power7" 2880 4000))
;

;
(class watson-1)     ; user.FictionalCharacter
(class watson-2)     ; user.SuperComputer
;

(should-result [true true]
  ;
  (instance? FictionalCharacter watson-1)     ; True.
  (instance? SuperComputer watson-2)          ; Nope.
  ;
)

(defn process-fictional-character [x])
(defn process-computer [x])
;
;; Don't do this!

(defn process-thing [x]
  (if (= (instance? FictionalCharacter x))
    (process-fictional-character x)
    (process-computer x)))
;

;
(defrecord Employee [first-name last-name department])
;

;
(def alice (->Employee "Alice" "Smith" "Engineering"))
;

;
(defprotocol Person
  (full-name [this])
  (greeting [this msg])
  (description [this]))
;

;
(defrecord FictionalCharacter[name appears-in author]
  Person
  (full-name [this] (:name this))
  (greeting [this msg] (str msg " " (:name this)))
  (description [this]
    (str (:name this) " is a character in " (:appears-in this))))


(defrecord Employee [first-name last-name department]
  Person
  (full-name [this] (str first-name " " last-name))
  (greeting [this msg] (str msg " " (:first-name this)))
  (description [this]
    (str (:first-name this) " works in " (:department this))))
;

;
(def sofia (->Employee "Sofia" "Diego" "Finance"))

(def sam (->FictionalCharacter "Sam Weller" "The Pickwick Papers" "Dickens"))
;


(should-result
  ["Sofia Diego"
   "Sam Weller is a character in The Pickwick Papers"
   "Hello! Sofia"]
  ;
  ;; Call the full-name method. Returns "Sofia Diego".

  (full-name sofia)

  ;; Call description.
  ;; Returns "Sam Weller is a character..."

  (description sam)

  ;; Returns "Hello! Sofia"

  (greeting sofia "Hello!")
  ;
)


;
(defprotocol Marketable
  (make-slogan [this]))
;

;
(extend-protocol Marketable
  Employee
    (make-slogan [e] (str (:first-name e) " is the BEST employee!"))
  FictionalCharacter
    (make-slogan [fc] (str (:name fc) " is the GREATEST character!"))
  SuperComputer
    (make-slogan [sc] (str "This computer has " (:no-cpus sc) " CPUs!")))
;

(should-match #"Bob is the BEST employee!"
  (make-slogan (->Employee "Bob" "Smith" "Janitor")))

(should-match #"Spock is the GREATEST character!"
  (make-slogan (->FictionalCharacter "Spock" "Star Trek" "Roddenberry")))

(should-match #"This computer has 2880"
  (make-slogan watson-2))

;
(extend-protocol Marketable
  String
    (make-slogan [s] (str \" s \" " is a string! WOW!"))
  Boolean
    (make-slogan [b] (str b  " is one of the two surviving Booleans!")))
;

(should-match #"\"hello\" is a string! WOW!"
  (make-slogan "hello"))

(should-match #"true is one of the two Booleans left in the nature!"
  (make-slogan true))


;
(require 'clostache.parser)

(def template "The book {{title}} is by {{author}}")

(def values {:title "War and Peace" :author "Tolstoy"})
;

(println (clostache.parser/render template values))

(should-match #"The book War and Peace is by Tolstoy"
  ;
  ;; Gives you "The book War and Peace is by Tolstoy"

  (clostache.parser/render template values)
  ;
)


;
(def data {:author "Tolstoy" :show-author true})

(def section-templ "{{#show-author}} by {{author}} {{/show-author}}")
;


;
(defrecord Section [name body start end inverted])
;

(comment
  ;
  (defn- render-section
    [section data partials]
     (let [section-data ((keyword (:name section)) data)]
       (if (:inverted section)
         (if (or (and (seqable? section-data)
                      (empty? section-data))
                 (not section-data))
           (:body section))
      ; Lots of code omitted
      )))
  ;
)

;
(defprotocol Lifecycle
  (start [component]
    "Begins operation of this component. Synchronous, does not return
  until the component is started. Returns an updated version of this
  component.")
  (stop [component]
    "Ceases operation of this component. Synchronous, does not return
  until the component is stopped. Returns an updated version of this
  component."))
;

;
(def test-component (reify Lifecycle
                     (start [this]
                       (println "Start!")
                       this)
                     (stop [this]
                       (println "Stop!")
                       this)))
;

(should-print "Start!\n" (start test-component))
(should-print "Stop!\n" (stop test-component))


;
;; A partial implementation of Lifecycle. We can call start, but
;; we will get an exception if we call stop.

(def dont-stop
  (reify Lifecycle
    (start [this]
      (println "Start!")
      this)))
;

(should-print "Start!\n" (start dont-stop))
(should-throw  (stop dont-stop))


(def the-char
  ;
  (map->FictionalCharacter {:full-name "Elizabeth Bennet"
                            :book "Pride & Prejudice"
                            :written-by "Austen"})
  ;
)

(should= "Elizabeth Bennet" (:full-name the-char))
(should= "Pride & Prejudice" (:book the-char))
(should= "Austen" (:written-by the-char))
(should= nil (:name the-char))
(should= nil (:appears-in the-char))
(should= nil (:author the-char))

;
(assoc elizabeth :book "Pride & Prejudice")
;

;
(defprotocol CollidingPerson
  (name [this])
  (greeting [this msg])
  (description [this]))
;

;
(defprotocol Person
  (full-name [this])
  (greeting [this msg])
  (description [this]))

(defprotocol Product
  (inventory-name [this])
  (description [this]))
;
