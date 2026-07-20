
fun main() {
    val options = arrayOf("Rock", "Paper", "Scissors")
    val gameChoice = getGameChoice(options)
    val userChoice = getUserChoice(options)
    printResults(userChoice, gameChoice)
}

fun getGameChoice(optionsParam: Array<String>) =
    optionsParam[(Math.random() * optionsParam.size).toInt()]

fun getUserChoice(optionsParam: Array<String>): String {
    var isValidChoice = false
    var userChoice = ""
    while(!isValidChoice) {
        // Ask the user their choice
        print("Please enter one of the following:")
        for (item in optionsParam) print(" $item")
        println(".")
        // Read the user input
        val userInput = readLine()
        // Validate the user input
        if (userInput != null && userInput.capitalize() in optionsParam) {
            isValidChoice = true
            userChoice = userInput
        }
        if (!isValidChoice) println("Please enter a valid choice")
    }
    return userChoice
}

fun printResults(userChoice: String, gameChoice: String) {
    val result: String
    if (userChoice == gameChoice) result = "Tie!"
    else if ((userChoice == "Rock" && gameChoice == "Scissors") ||
        (userChoice == "Paper" && gameChoice == "Rock") ||
        (userChoice == "Scissors" && gameChoice == "Paper")) result = "You win!"
    else result = "You lose!"
    // Print the result
    println("You chose $userChoice. I chose $gameChoice. $result")
}