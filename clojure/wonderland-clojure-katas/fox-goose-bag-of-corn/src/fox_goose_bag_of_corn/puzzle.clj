(ns fox-goose-bag-of-corn.puzzle)

(def start-pos [[[:fox :goose :corn :you] [:boat] []]])

(defn river-crossing-plan []
  (conj start-pos
   [[:fox :corn][:goose :boat :you][]]
   [[:fox :corn][:boat][:goose :you]]
   [[:fox :corn][:boat :you][:goose]]
   [[:you :fox :corn][:boat][:goose]]
   [[:fox][:corn :boat :you][:goose]]
   [[:fox][:boat][:corn :goose :you]]
   [[:fox][:goose :boat :you][:corn]]
   [[:goose :fox :you][:boat][:corn]]
   [[:goose][:boat :fox :you][:corn]]
   [[:goose][:boat][:corn :fox :you]]
   [[:goose][:boat :you][:corn :fox]]
   [[:goose :you][:boat][:corn :fox]]
   [[][:boat :goose :you][:corn :fox]]
   [[][:boat][:goose :you :corn :fox]]))
