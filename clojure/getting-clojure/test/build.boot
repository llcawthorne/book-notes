(set-env!
  :source-paths #{"../util"}
  :dependencies '[[org.clojure/clojure "1.9.0-alpha16"]
                  [org.clojure/test.check "0.9.0"]
                  [midje "1.9.0-alpha9"]])

(defn run-file [p]
  (println "Running " p "...")
  (load-file p))

(deftask runtest []
  (with-pass-thru _
    (run-file "trouble_one.clj")
    (run-file "trouble_two.clj")
    (run-file "sample_generators.clj")))
