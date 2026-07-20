/*
 * The Babylonian Square Root Method
 *
 * 1. Start with an initial estimate, `guess`, for the square root of a
 *    positive number `N`. This is customarily set to `N / 2`.
 * 2. Check to see if the absolute value of `(guess * guess - N)` is
 *    less than the tolerance value. If yes, then terminat the loop and
 *    return the estimated square root.
 * 3. Otherwise, update the guess using the formula
 *    `guess = (guess + N / guess) / 2.0`.
 * 4. Repeat steps 2 and 3 until the stopping condition is met.
 *
 */

fun babylonianSquareRoot(num: Double): Double {
    val TOL = 0.000001
    var iter = 1
    var guess = num / 2.0

    while (Math.abs(guess * guess - num) > TOL) {
        println("iter: $iter  guess=$guess")
        guess = (guess + num / guess) / 2.0
        iter++
    }
    return guess
}

fun main() {
    println("\n*** Finding Square Root Using Babylonian Algorithm ***\n")
    println("Enter a number (>=1) to find its square root:")
    val num = readLine()?.toDoubleOrNull()
    if (num != null && num >= 1) {
        println("You have entered: $num\n")
        val squareRoot = babylonianSquareRoot(num)
        println("\nThe estimated square root of $num is: $squareRoot\n")
    }
}
