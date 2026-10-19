;---
; Excerpted from "Programming Clojure, Fourth Edition",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/shcloj4 for more book information.
;---
; The START:/END: pairs are production artifacts for the book and not 
; part of normal Clojure style

(ns examples.snake
  (:import (java.awt Color Dimension Graphics) 
    (javax.swing JPanel JFrame Timer JOptionPane)
    (java.awt.event ActionListener KeyListener KeyEvent
                    WindowAdapter WindowEvent)))

; ----------------------------------------------------------
; functional model
; ----------------------------------------------------------
(def width 75)        ;; Game board width
(def height 50)       ;; Game board height
(def point-size 10)   ;; Pixels per point
(def turn-millis 50)  ;; Time (ms) between turns
(def win-length 5)    ;; Snake segments to win
(def dirs { KeyEvent/VK_LEFT  [-1  0] 
            KeyEvent/VK_RIGHT [ 1  0]
            KeyEvent/VK_UP    [ 0 -1] 
            KeyEvent/VK_DOWN  [ 0  1]})

(defn add-points [& pts] 
  (vec (apply map + pts)))

(defn point-to-screen-rect [pt] 
  (map #(* point-size %) 
       [(pt 0) (pt 1) 1 1]))

(defn create-apple [] 
  {:location [(rand-int width) (rand-int height)]
   :color (Color. 210 50 90)
   :type :apple}) 

(defn create-snake []
  {:body (list [1 1]) 
   :dir [1 0]
   :type :snake
   :color (Color. 15 160 70)})

(defn move [{:keys [body dir] :as snake} & grow]
  (assoc snake :body (cons (add-points (first body) dir) 
			   (if grow body (butlast body)))))

(defn turn [snake newdir] 
  (assoc snake :dir newdir))

(defn win? [{body :body}]
  (>= (count body) win-length))

(defn head-overlaps-body? [{[head & body] :body}]
  (contains? (set body) head))

(def lose? head-overlaps-body?)

(defn eats? [{[snake-head] :body} {apple :location}]
   (= snake-head apple))

; ----------------------------------------------------------
; mutable model
; ----------------------------------------------------------
(defn update-positions [snake apple]
  (dosync
   (if (eats? @snake @apple)
     (do (ref-set apple (create-apple))
	 (alter snake move :grow))
     (alter snake move)))
  nil)

(defn update-direction [snake newdir]
  (when newdir (dosync (alter snake turn newdir))))

(defn reset-game [snake apple]
  (dosync (ref-set apple (create-apple))
	  (ref-set snake (create-snake)))
  nil)

; ----------------------------------------------------------
; gui
; ----------------------------------------------------------
(defn fill-point [^Graphics g pt color] 
  (let [[x y width height] (point-to-screen-rect pt)]
    (.setColor g color) 
    (.fillRect g x y width height)))

(defmulti paint (fn [g object & _] (:type object)))

(defmethod paint :apple [g {:keys [location color]}] 
  (fill-point g location color))

(defmethod paint :snake [g {:keys [body color]}] 
  (doseq [point body]
    (fill-point g point color)))

(defn game-panel [frame snake apple]
  (proxy [JPanel ActionListener KeyListener] []
    (paintComponent [^Graphics g] 
      (proxy-super paintComponent g)
      (paint g @snake)
      (paint g @apple))
    (actionPerformed [e] 
      (update-positions snake apple)
      (when (lose? @snake)
	(reset-game snake apple)
	(JOptionPane/showMessageDialog frame "You lose!"))
      (when (win? @snake)
	(reset-game snake apple)
	(JOptionPane/showMessageDialog frame "You win!"))
      (.repaint ^JPanel this))
    (keyPressed [^KeyEvent e] 
      (update-direction snake (dirs (.getKeyCode e))))
    (getPreferredSize [] 
      (Dimension. (* (inc width) point-size) 
		  (* (inc height) point-size)))
    (keyReleased [e])
    (keyTyped [e])))

(defn game [] 
  (let [snake (ref (create-snake)) 
	apple (ref (create-apple))
	frame (JFrame. "Snake")
	panel ^JPanel (game-panel frame snake apple)
	timer (Timer. turn-millis panel)]
    (doto panel 
      (.setFocusable true)
      (.addKeyListener panel))
    (doto frame 
      (.add panel)
      (.pack)
      (.setDefaultCloseOperation JFrame/DISPOSE_ON_CLOSE)
      (.addWindowListener
        (proxy [WindowAdapter] []
          (windowClosing [^WindowEvent e]
            (.stop timer)
            (.dispose frame))))
      (.setVisible true))
    (.start timer) 
    [snake, apple, timer])) 

