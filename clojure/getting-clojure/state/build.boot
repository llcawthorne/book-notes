(set-env!
  :source-paths #{"../util"}
  :dependencies '[[org.clojure/clojure "1.8.0"]
                  [org.clojure/clojure "1.9.0-alpha16"]])

(deftask runtest []
  (with-pass-thru _
    (load-file "examples.clj")))
