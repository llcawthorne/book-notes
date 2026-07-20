
fun main() {
    // Array's are always mutable objects
    val wordArray1 = arrayOf("24/7", "multi-tier", "B-to-B", "dynamic", "pervasive")
    val wordArray2 = arrayOf("empowered", "leveraged", "aligned", "targeted")
    val wordArray3 = arrayOf("process", "paradigm", "solution", "portal", "vision")

    val arraySize1 = wordArray1.size
    val arraySize2 = wordArray2.size
    val arraySize3 = wordArray3.size

    val rand1 = kotlin.random.Random.nextInt(arraySize1)  // the new way is to use kotlin.random
    val rand2 = (Math.random() * arraySize2).toInt()
    val rand3 = (Math.random() * wordArray3.size).toInt()       // we don't have to use arraySize3

    val phrase = "${wordArray1[rand1]} ${wordArray2[rand2]} ${wordArray3[rand3]}"
    println(phrase)
}