import kotlin.math.E
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.log
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt
import kotlin.math.tan
import kotlin.system.exitProcess

fun main() {
    println("*** Console Calculator ***")

    // step 1: operation selection
    showChoices()
    val operation = getArithmeticOperation()
    val operandCount: Int
    when (operation) {
        "+", "-", "*", "/", "%", "^" -> operandCount = 2
        "sqrt", "sin", "cos", "tan", "log", "exp" -> operandCount = 1
        else -> {
            println("Invalid operation. Exiting.")
            exitProcess(2)
        }
    }

    // step 2: input collection
    println("\nEnter one or two numbers:\n")
    val number1 = readDoubleInput("Number 1: ")
    val number2 = readDoubleInput("Number 2 (or ENTER): ")

    // step 3: calculation
    val result = performCalculation(number1, number2, operation)

    // step 4: result display
    println("\nResult:\n" +
                if (operandCount==1) "$operation $number1 = $result"
                else "$number1 $operation $number2 = $result")
}

fun readDoubleInput(prompt: String): Double {
    print(prompt)
    val num = readln()

    // Check input validity
    try {
        return num.toDouble()
    } catch (e: Exception) {
        if (num == "") return 0.0
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
    println("7. Square Root (sqrt)")
    println("8. Sine x (sin)")
    println("9. Cosine x (cos)")
    println("10. Tangent x (tan)")
    println("11. log_e (log)")
    println("12. Exponential: e^x (exp)")
    println("Note: For trig functions, number is taken to be degrees.")
}

fun getArithmeticOperation(): String {
    print("Enter an arithmetic operation (+, -, *, /, %, ^, sqrt, sin, cos, tan, log, exp): ")
    val operation = readln()

    // sometimes I hit 1-4 because of showChoices format, so I'm
    // making that "not an error"
    when (operation) {
        "1" -> return "+"
        "2" -> return "-"
        "3" -> return "*"
        "4" -> return "/"
        "5" -> return "%"
        "6" -> return "%"
        "7", "sqrt" -> return "sqrt"
        "8", "sin" -> return "sin"
        "9", "cos" -> return "cos"
        "10", "tan" -> return "tan"
        "11", "log" -> return "log"
        "12", "exp" -> return "exp"
        else -> if (!"+-*/%^".contains(operation, true)) {
                println("Invalid operation. Exiting.")
                exitProcess(2)  // Exit with error code 2
            }
   }

    return operation
}

fun performCalculation(number: Double, operation: String): Double {
    return when (operation){
        "sqrt" -> sqrt(number)
        "sin" -> sin(Math.toRadians(number))
        "cos" -> cos(Math.toRadians(number))
        "tan" -> tan(Math.toRadians(number))
        "log" -> log(number, E)
        "exp" -> exp(number)
        "+", "-", "*", "/", "^" -> {
            println("performOperation called with a single number for a dual operation")
            exitProcess(4)
        }
        else -> {
            println("\nUnexpected error encountered. Exiting.")
            exitProcess(6)
        }
    }
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
        "sqrt" -> performCalculation(number1, operation)
        "sin" -> performCalculation(number1, operation)
        "cos" -> performCalculation(number1, operation)
        "tan" -> performCalculation(number1, operation)
        "log" -> performCalculation(number1, operation)
        "exp" -> performCalculation(number1, operation)
        else -> {
            println("\nUnexpected error encountered. Exiting.")
            exitProcess(5)
        }
    }
}