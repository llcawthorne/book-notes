/* KOTLIN FROM SCRATCH - Faisal Islam */
/* Projects 17: Predict the Flight of a Cannonball */
/*
 * This project uses a numerical method to estimate the angle
 * necessary to fire a cannon at height 25 m to hit a target
 * 400 m away assuming the shot is fired at 70 m/s. 
 * We use a method called bisection:
 *
 * 1. Locate two values x_1 and x_2 such that f(x_1) < 0 and f(x_2) > 0, 
 *    which means the values are on opposite sides of the root when f(x) = 0.
 * 2. Find the midpoint x between x_1 and x_2 such that x = (x_1 + x_2) / 2.
 * 3. If the absolute value of f(x) is less than some tolerance factor, 
 *    say 0.0000001, then x is the root so we're done.
 * 4. Otherwie if f(x) * f(x_2) > 0 set x_2 = x else set x_1 = x.
 * 5. Repeat steps 2 through 4 until the condition in step 3 is met.
 *
 */

// import math functions
import kotlin.math.sin
import kotlin.math.cos
import kotlin.math.PI
import kotlin.math.sqrt
import kotlin.math.pow
import kotlin.math.abs

// set global parameters
val v0 = 70             // m/s
val g = 9.8             // m/s2
val h0 = 25             // m
val target = 400        // m
val TOL = 1.0e-7

// This is so we can use `projectile` as f(x) and call it f
private val f = :: projectile

// the interval [x1, x2] needs to enclose the root
val x1 = 10.0    //in degrees
val x2 = 30.0    //in degrees

// ------------------------------------------------------------------------

fun main() {
    println("\n*** Firing angle for hitting a target ***\n")

    // f(x1) and f(x2) need to be on opposite sides of the root of the
    // equation (when f(x) = 0), so one is negative and the other positive
    // hence their product is negative.
    if (f(x1) * f(x2) < 0) {
        println("...Initial guesses are valid...")
        val root = bisection(x1, x2)
        val rootFormatted = String.format("%.2f", root)
        println("The firing angle to hit the target is:" +
                "\n$rootFormatted degrees")
    } else {
        println("\n...Initial guesses are not valid...\n")
    }
}

// ------------------------------------------------------------------------

fun projectile(angle: Double): Double {
    val x = angle * PI / 180.0
    return target - (v0 * cos(x) / g) *
            (v0 * sin(x) + sqrt((v0 * sin(x)).pow(2) + 2 * g * h0))
}

// ------------------------------------------------------------------------

fun bisection(
    x1: Double,
    x2: Double,
): Double {
    var x1 = _x1
    var x2 = _x2
    var x = (x1 + x2) / 2.0

    while (abs(f(x)) >= TOL) {
        if (f(x) * f(x2) > 0) {
            x2 = x
        } else {
            x1 = x
        }
        x = (x1 + x2) / 2.0
    }
    return x
}
