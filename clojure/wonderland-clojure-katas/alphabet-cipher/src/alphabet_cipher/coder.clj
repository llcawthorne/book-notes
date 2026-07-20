(ns alphabet-cipher.coder)

(def alphabet [\a \b \c \d \e \f \g \h \i \j \k \l \m \n \o \p \q \r \s \t \u \v \w \x \y \z])

(defn- letter-to-int [c]
  (.indexOf alphabet c))

(defn- rotate-list [lst n]
  (let [n (rem n (count lst))]
    (concat (drop n lst) (take n lst))))

(def rotateAlphabet 
  (comp vec (partial rotate-list alphabet)))

(def cipherTable
  (into [] (map rotateAlphabet) (range 26)))

(defn- encode-letter [s c]
  "Takes a letter from a keyword string and a letter and provides the encrypted value."
  (let [c (letter-to-int c)
        r (letter-to-int s)]
    ((cipherTable c) r)))

(defn- decode-letter [s c]
  "Take a letter from a keyword string and an encrypted letter and provides the decrypted value."
  (let [r (letter-to-int s)]
    (alphabet (.indexOf (cipherTable r) c))))

(defn- transpose [m]
  (apply mapv vector m))

(defn- decipher-letter [e c]
  (let [c (letter-to-int c)]
    (alphabet (.indexOf ((transpose cipherTable) c) e))))

(defn- find-repeating-str [s]
  (loop [n 1]
    (if (> n (count s))
      s
      (let [t (take n s)]
        (if (= (apply str (take (count s) (cycle t))) s)
          (apply str t)
          (recur (inc n)))))))

(defn encode [secret message]
  (apply str (map encode-letter (cycle secret) message)))

(defn decode [secret message]
  (apply str (map decode-letter (cycle secret) message)))

(defn decipher [cipher message]
  (find-repeating-str (apply str (map decipher-letter cipher message))))

