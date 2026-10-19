;---
; Excerpted from "Programming Clojure, Fourth Edition",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/shcloj4 for more book information.
;---
(ns examples.note
  (:import [javax.sound.midi MidiSystem]))

(defprotocol MidiNote
  :extend-via-metadata true

  (msec [this tempo] "Note duration in ms")
  (key-number [this] "MIDI key number")
  (velocity [this]   "MIDI velocity"))

;; Assumes whole note = 4 beats
(defn beats->msec [beats tempo]
  (* (/ beats tempo) 4 60 1000))

(defn note->key [pitch octave]
  (let [scale {:C 0,  :C# 1, :Db 1,  :D 2,
               :D# 3, :Eb 3, :E 4,   :F 5,
               :F# 6, :Gb 6, :G 7,   :G# 8,
               :Ab 8, :A 9,  :A# 10, :Bb 10,
               :B 11}]
    (+ (* 12 (inc octave)) (scale pitch))))

(defrecord Note [pitch octave duration])

(extend-type Note
  MidiNote
  (msec [this tempo] 
    (beats->msec (:duration this) tempo))
  (key-number [this]
    (note->key (:pitch this) (:octave this)))
  (velocity [this]
    (or (:velocity this) 64)))

(defn perform [notes & {:keys [tempo] :or {tempo 120}}]
  (with-open [synth (doto (MidiSystem/getSynthesizer) .open)]
    (let [channel (aget (.getChannels synth) 0)]
      (doseq [note notes]
        (.noteOn channel (key-number note) (velocity note))
        (Thread/sleep (long (msec note tempo)))))))

(comment

(let [min-duration 250
      min-velocity 64
      rand-note (reify MidiNote
                  (msec [_ tempo] (+ (rand-int 1000) min-duration))
                  (key-number [_] (rand-int 100))
                  (velocity [_] (+ (rand-int 100) min-velocity)))]
  (perform (repeat 15 rand-note)))
)

                                        
                                        
;; To do item with estimated times in minutes
(defrecord ToDo [desc est type])

(def todo-list
  [(->ToDo "Grocery shopping" 60 :errand)
   (->ToDo "Mow yard"         30 :house)
   (->ToDo "Brush teeth"      2  :personal)
   (->ToDo "Walk dog"         10 :house)
   (->ToDo "Call mom"         15 :personal)])

(defn to-note [todo theme]
  (let [{:keys [est type]} todo
        {:keys [mpb pitches volume]} theme
        octave 4]
    (with-meta todo
      {`msec (fn [_ bpm] (beats->msec (/ est mpb) bpm))
       `key-number (fn [_] (note->key (get pitches type) octave))
       `velocity (constantly volume)})))

(defrecord Theme [mpb pitches volume])

(def default-theme 
  (->Theme 60 {:errand :C, :house :E, :personal :G} 64))

(defn play-todos [todos theme]
  (perform (map #(to-note % theme) todos)))


(comment
  (def close-encounters [(->Note :D 3 1/2)
                         (->Note :E 3 1/2)
                         (->Note :C 3 1/2)
                         (->Note :C 2 1/2)
                         (->Note :G 2 1/2)])

  (perform (map #(update-in % [:octave] dec) close-encounters))
  (perform (for [velocity [64 80 90 100 110 120]]
             (assoc (Note. :D 3 1/2) :velocity velocity)))

  (let [min-duration 250
        min-velocity 64
        rand-note (reify MidiNote
                    (msec [_ tempo] (+ (rand-int 1000) min-duration))
                    (key-number [_] (rand-int 100))
                    (velocity [_] (+ (rand-int 100) min-velocity)))]
    (perform (repeat 15 rand-note)))
  )