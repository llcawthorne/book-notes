import kotlin.math.pow
import kotlin.system.exitProcess

fun main() {
    println("*** Console Calculator ***")

    // step 1: operation selection
    showChoices()
    val operation = getArithmeticOperation()

    // step 2: input collection
    println("\nEnter two numbers:\n")
    val number1 = readDoubleInput("Number 1: ")
    val number2 = readDoubleInput("Number 2: ")

    // step 3: calculation
    val result = performCalculation(number1, number2, operation)

    // step 4: result display
    println("\nResult:\n" +
                "$number1 $operation $number2 = $result")
}

fun readDoubleInput(prompt: String): Double {
    print(prompt)
    val num = readln()

    // Check input validity
    try {
        return num.toDouble()
    } catch (e: Exception) {
        println("Error reading input: ${e.message}")
        exitProcess(1)  // exit with error code 1
    }
}

fun showChoices() {
    println("\nOperation options:")
    println("1. Addition (+)")
    println("2. Subtraction (-)")
    println("3. Multiplication (*)")
    println("4. Division (/)")
    println("5. Modulo (%)")
    println("6. Exponentiation (^)")
}

fun getArithmeticOperation(): String {
    print("Enter an arithmetic operation (+, -, *, /, %, ^): ")
    val operation = readln()

    // sometimes I hit 1-4 because of showChoices format, so I'm
    // making that "not an error"
    when (operation) {
        "1" -> return "+"
        "2" -> return "-"
        "3" -> return "*"
        "4" -> return "/"
        "5" -> return "%"
        "6" -> return "^"
        else -> if (!"+-*/%^".contains(operation, true)) {
                println("Invalid operation. Exiting.")
                exitProcess(2)  // Exit with error code 2
            }
   }

    return operation
}

fun performCalculation(number1: Double, number2: Double,
                       operation: String): Double {
    return when (operation) {
        "+" -> number1 + number2
        "-" -> number1 - number2
        "*" -> number1 * number2
        "/" -> if (number2 != 0.0) number1 / number2
               else {
                    println("\nDivision by zero is not allowed. Exiting.")
                    exitProcess(3)
               }
        "%" -> if (number2 != 0.0) number1 % number2
               else {
                   println("\nModulus by zero is not allowed. Exiting.")
                   exitProcess(3)
               }
        "^" -> number1.pow(number2)
        else -> {
            println("\nUnexpected error encountered. Exiting.")
            exitProcess(5)
        }
    }
}