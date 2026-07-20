;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---

(ns ring-example.core
  (:require [ring.adapter.jetty :as jetty]))

;; These handler examples are adapted from the Ring documentation.

;
(defn log-value
  "Log the message and the value. Returns the value."
  [msg value]
  (println msg value)
  value)

(defn wrap-logging
  "Return a function that logs the response."
  [msg handler]
  (fn [request]
    (log-value msg (handler request))))
;

;
(defn wrap-content-type
  "Return a function that sets the response content type."
  [handler content-type]
  (fn [request]
    (assoc-in
      (handler request)
      [:headers "Content-Type"]
      content-type)))
;

;
(defn handler [request]
  {:status 200
   :body "Hello from your web application!"})

(def app
  (wrap-logging
    "Final response:"
    (wrap-content-type handler "text/html")))
;

(do
;
(def app
  (wrap-content-type
    (wrap-logging  "Initial response:" handler)
    "text/html"))
;
)

(comment
;
(def app
  (wrap-logging
    "Final response:"
    (wrap-content-type
      (wrap-logging  "Initial response:" handler)
      "text/html")))
;
)

;
(defn -main []
  (jetty/run-jetty app {:port 8080}))
;
