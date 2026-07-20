fun main() {
    println("Enter your age:")
    val age = readln()

    if (age.toInt() < 18) println("You are not eligible to vote yet.")
    else if (age.toInt() in 18..120) println("You are eligible to vote.")
    else if (age.toInt() > 120) println("Please enter a valid age.")

    when(age.toInt()) {
        in Int.MIN_VALUE..18 -> println("You are not eligible to vote yet.")
        in 18..120 -> println("You are eligible to vote.")
        else -> println("Please enter a valid age.")
    }
}