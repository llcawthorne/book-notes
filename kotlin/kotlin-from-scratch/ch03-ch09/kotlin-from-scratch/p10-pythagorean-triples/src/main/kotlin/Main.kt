/*
 * Euclid's Formula for Pythagorean Triples
 *
 * 1. Choose an arbitrary positive integer `k`.
 * 2. Choose a pair of positive integers `m` and `n`, such that m > n > 0.
 * 3. Calculate `a = k(m^2 - n^2)`, `b = 2kmn`, and `c = k(m^2 + n^2)`.
 * 4. The values `a`, `b`, and `c` form a Pythagorean triple (`a, b, c`).
 *
 */

fun generatePythagoreanTriple(m: Int, n: Int): Triple<Int, Int, Int> {
    val a = m * m - n * n
    val b = 2 * m * n
    val c = m * m + n * n
    return Triple(a, b, c)
}

fun main() {
    var m = 2
    var n = 1
    val numTriples = 10

    println("\n*** Pythagorean Triples Using Euclid's Formula ***\n")
    println("Number of Pythagorean triples: $numTriples\n")

    // Generate the first "numTriples" triples.
    for (i in 1..numTriples) {
        val pythagoreanTriple = generatePythagoreanTriple(m, n)
        print("i=${"%2d".format(i)}   " +
              "m=${"%2d".format(m)}   n=${"%2d".format(n)}  ")
        println("Pythagorean triple: $pythagoreanTriple")
        n++
        m++
    }
}
