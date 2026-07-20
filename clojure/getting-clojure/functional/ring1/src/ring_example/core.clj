;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;
(ns ring-example.core
  (:require [ring.adapter.jetty :as jetty]))
;

;
(defn handler [request]
  {:status 200
   :headers {"Content-Type" "text/html"}
   :body "Hello from your web application!"})
;

;
(defn -main []
  (jetty/run-jetty handler {:port 8080}))
;
