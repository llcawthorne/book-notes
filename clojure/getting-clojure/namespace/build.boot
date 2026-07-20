(set-env!
  :source-paths #{"../util"}
  :dependencies '[[org.clojure/clojure "1.9.0-alpha14"]
                  [org.clojure/test.check "0.9.0"]])

(deftask runtest []
  (with-pass-thru _
    (load-file "examples.clj")))
