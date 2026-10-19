;---
; Excerpted from "Clojure Brain Teasers",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/mmclobrain for more book information.
;---


;; Define the subject as list of notes
(def subject ["A" "D" "E" "A"])

;; Define generic procedure with multi arity options
(defmulti play (fn [pattern transformation &args] transformation))

;; Returns subject, does not modify
(defmethod play :default [_ _] subject)

;; Reverses subject
(defmethod play :retrograde [_ _] (reverse subject))

;; Changes the key
(defmethod play :transpose-minor [_ _] (map #(str % "m") subject))

;; Creates crab canon
(defmethod play :mobius [_ _]
  (let [half (quot (count subject) 2)       ;; find half of the subject
        first-half (subvec subject 0 half)  ;; create list of the first half
        second-half (reverse (subvec subject half))] ;; create list of second half, reverse
    (concat first-half second-half first-half))) ;; combine into continous mobius strip

(comment

  (play "original" :default)
  ;; => ["A" "D" "E" "A"]

  (play "backwards" :retrograde)
  ;; => ("A" "E" "D" "A")

  (play "to-minor-key" :transpose-minor)
  ;; => ("Am" "Dm" "Em" "Am")

  (play "crab-canon" :mobius)
  ;; => ("A" "D" "A" "E" "A" "D")
;
  )
