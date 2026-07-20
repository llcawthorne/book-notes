(set-env!
  :source-paths #{"../util"}
  :dependencies '[[org.clojure/clojure "1.8.0"]])

(deftask runtest []
  (with-pass-thru _
       (load-file "examples.clj")))
