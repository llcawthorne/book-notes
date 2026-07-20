/*
 * The Sieve of Eratosthenes
 *
 * 1. Create a list of consecutive integers from 2 through the given limit.
 * 2. Starting with 2 (the first prime), mark all its multiples as composite.
 * 3. Find the next number in the list that isn't marked as composite. This
 *    will be the next prime number.
 * 4. Mark all multiples of the prime number found in step 3 as composite.
 * 5. Repeat steps 3 and 4 until the square of the next prime number exceeds
 *    the given limit.
 * 6. The unmarked number in the list are all prime numbers.
 *
 * We will perform an optimization. When marking multiples of each prime
 * number, you can start from its square since all lower composite numbers
 * had a smaller factor so have already been crossed out.
 *
 */

fun sieveOfEratosthenes(n: Int): List<Int> {
    // Create a Boolean array with all values set to true.
    val primes = BooleanArray(n + 1) { true }
    // Create a mutable list of integers to save prime numbers.
    val primeNumbers = mutableListOf<Int>()

    // Set 0 and 1 to not be prime.
    primes[0] = false
    primes[1] = false

    // Iterate over all numbers until i^2 > N
    var i = 2
    while (i * i <= n) {
        // If i is prime, mark all multiples of i as not prime.
        if (primes[i]) {
            for (j in i * i..n step i) {
                primes[j] = false
            }
        }
        i++
    }

    // Collect all prime numbers into a list and return it.
    for ((index, value) in primes.withIndex()) {
        if (value) primeNumbers.add(index)
    }

    return primeNumbers
}

fun main() {
    println("*** Find All Prime Numbers Up to 'n' ***\n")
    println("Enter a number > 2 to generate the list of primes:")
    val num = readLine()?.toInt()
    if (num != null) {
        println("You have entered: $num")

        val primeNumbers = sieveOfEratosthenes(num)
        println("\nThe prime numbers <= $num are:")
        printPrimes(primeNumbers)
    } else {
        println("Received invalid input!")
    }
}

fun printPrimes(primeNumbers: List<Int>) {
    for (i in primeNumbers.indices) {
        if (i != 0 && i % 6 == 0) println()
        print("${"%8d".format(primeNumbers[i])} ")
    }
}
