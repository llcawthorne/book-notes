;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; State

(ns user
  (:require [testsupport :refer :all]))

;
(def counter 0)
(defn greeting-message [req]
  (if (zero? (mod counter 100))
    (str "Congrats! You are the " counter " visitor!")
    (str "Welcome to Blotts Books!")))
;; ect
;

(def counter 1)
(should-match #"Welcome" (greeting-message {}))

(def counter 200)
(should-match #"Congrats" (greeting-message {}))

;
(def counter (atom 0))

(defn greeting-message [req]
  (swap! counter inc)
  (if (= @counter 500)
    (str "Congrats! You are the " @counter " visitor!")
    (str "Welcome to Blotts Books!")))

;; ect
;

(should-match #"Welcome" (greeting-message {}))
(while (< @counter 499) (greeting-message {}))
(should-match #"Congrats" (greeting-message {}))

;
(swap! counter inc)
;

(should= @counter 501)

(reset! counter 0)

;
(swap! counter + 12)
;

(should= @counter 12)

;
(ns inventory)

(def by-title (atom {}))

(defn add-book [{title :title :as book}]
  (swap! by-title #(assoc % title book)))

(defn del-book [title]
  (swap! by-title #(dissoc % title )))

(defn find-book [title]
  (get @by-title title))
;

(testsupport/should-result [_f _ _ _ _t _f]
  ;
  (find-book "Emma")    ; Nope

  (add-book {:title "1984", :copies 1948})
  (add-book {:title "Emma", :copies 100})
  (del-book "1984")

  (find-book "Emma")    ; Yup
  (find-book "1984")    ; Nope
  ;
)


;
(ns inventory)

(def by-title (atom {}))

(def total-copies (atom 0))

(defn add-book [{title :title :as book}]
  (swap! by-title #(assoc % title book))

  ;; Oh no! The two atoms are out of sync right here!

  (swap! total-copies + (:copies book)))
;

(testsupport/should= @total-copies 0)
(add-book {:title "Emma", :copies 100})
(testsupport/should= @total-copies 100)
(add-book {:title "2001", :copies 200})
(testsupport/should= @total-copies 300)
(testsupport/should (find-book "Emma"))
(testsupport/should (find-book "2001"))
(testsupport/should (not (find-book "xxxxx")))

;
(ns inventory)

(def by-title (ref {}))

(def total-copies (ref 0))
;

;
(defn add-book [{title :title :as book}]
  (dosync
    (alter by-title #(assoc % title book))
    (alter total-copies + (:copies book))))
;

(testsupport/should= @total-copies 0)
(add-book {:title "Emma", :copies 100})
(testsupport/should= @total-copies 100)
(add-book {:title "2001", :copies 200})
(testsupport/should= @total-copies 300)
(testsupport/should (find-book "Emma"))
(testsupport/should (find-book "2001"))
(testsupport/should (not (find-book "xxxxx")))


(def change-count (atom 0))

(defn notify-inventory-change [op item]
  (swap! change-count inc)
  item)

;
(def by-title (atom {}))

(defn add-book [{title :title :as book}]
  (swap!
    by-title
    (fn [by-title-map]
      (notify-inventory-change :add book)
      (assoc by-title-map title book))))

;; Similar logic in del-book.
;

(testsupport/should= @change-count 0)
(add-book {:title "Emma", :copies 100})
(testsupport/should= @change-count 1)


(reset! change-count 0)

;
(ns inventory)

(def by-title (agent {}))

(defn add-book [{title :title :as book}]
  (send
    by-title
    (fn [by-title-map]
      (assoc by-title-map title book))))

;; Similar logic in del-book.
;


;
(defn add-book [{title :title :as book}]
  (send
    by-title
    (fn [by-title-map]
      (notify-inventory-change :add book)
      (assoc by-title-map title book))))
;


(testsupport/should= @change-count 0)
(add-book {:title "Emma", :copies 100})
(add-book {:title "2001", :copies 100})

(Thread/sleep 250)                     ; Bogus but easy!

(testsupport/should= @change-count 2)
(testsupport/should= (count @by-title) 2)


;
;; Queue up and add book request.

(add-book {:title "War and Peace" :copies 25})

;; At this point the agent may or may not have been updated.
;

(testsupport/should= (count @by-title) 3)

;
(defn blurb [book]
  (str "Don't miss the exciting new book, "
       (:title book)
       " by "
       (:author book)))
;

;
(def memoized-blurb (memoize blurb))
;

;
(def emma {:title "Emma" :author "Austen"})

;; Only calls the blurb function once.
(memoized-blurb emma)
(memoized-blurb emma)
(memoized-blurb emma)
;

(testsupport/should-match #"Don't.*Emma.*Austen" (memoized-blurb emma))

;; The following code is derived from the Clojure source.

(comment
  ;
  (defn memoize
    "Returns a memoized version of a referentially
    transparent function. The memoized version of
    the function keeps a cache of the mapping from
    arguments to results and, when calls with the
    same arguments are repeated often, has
    higher performance at the expense of higher
    memory use."
    [f]
    (let [mem (atom {})]
      (fn [& args]
        (if-let [e (find @mem args)]
          (val e)
          (let [ret (apply f args)]
            (swap! mem assoc args ret)
            ret)))))
  ;
)

;
(def title-atom (atom "Pride and Prejudice"))
;

;
(swap! title-atom #(str % " and Zombies"))
;



;
(def title-agent (agent "A Night to Remember"))

;; BOOM! You can't add 99 to a string!

(send title-agent + 99)
;


(Thread/sleep 100)
(testsupport/should (agent-error title-agent))

;
;; If the agent is dead then restart it with a new value
;; and clear any pending updates.

(if (agent-error title-agent)
  (restart-agent
    title-agent
    "Poseidon Adventure"
    :clear-actions true))
;

(testsupport/should (not (agent-error title-agent)))

;
(defn -main []
  ;; Do some stuff with agents.

  ;; Shut down the threads that have been running the agent updates
  ;; so that the JVM will actually shut down.

  (shutdown-agents))
;

(-main)
