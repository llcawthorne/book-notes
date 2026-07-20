/*
 * Calculate the Earth's Circumference like Erastothenes
 *
 * It's all straight trigonometry, but requires at least four equations.
 * I believe understanding it is probably impossible without the diagram.
 * But I'll put the equations anyway:
 *
 * $$
 * \begin{aligned}
 * \theta &= \arctan \left(\frac{s}{h}\right)            \tag{4.1}\\
 * \theta_{2} &= \theta_1 + \alpha                                \\
 * \alpha &= \theta_2 - \theta_1                         \tag{4.2}\\
 * \frac{\alpha}{d} &= \frac{2\pi}{\text{Circumference}}          \\
 * \text{Circumference} &= \frac{2\pi d}{\alpha}         \tag{4.3}\\
 * r &= \frac{\text{Circumference}}{2\pi}                         \\
 * R &= \frac{d}{\alpha}                                 \tag{4.4}
 * \end{aligned}
 * $$
 *
 * The diagram is on e-page 130 of the text and the explanation starts
 * there and extends to e-page 131. It's bookmarked in my copy.
 */

import kotlin.math.atan

data class Earth(
    val alpha: Double,
    val circumference: Int,
    val radius: Int,
)

fun calculateEarthMetrics(
    s1: Double,
    h1: Double,
    s2: Double,
    h2: Double,
    d: Double,
): Earth {
    // Calculuate the angles of the shadows.
    val theta1 = atan(s1 / h1)
    val theta2 = atan(s2 / h2)

    // Calculate the angle at the center of Earth.
    val alpha = theta2 - theta1

    // Calculate the circumference and radius.
    val circumference = (2 * Math.PI * d / alpha).toInt()
    val radius = (d / alpha).toInt()

    return Earth(alpha, circumference, radius)
}

fun main() {
    // known values
    val shadow1 = 0.0 // in m
    val height1 = 7.0 // in m
    val shadow2 = 0.884 // in m
    val height2 = 7.0 // in m
    val distanceBetweenCities = 800.0 // in km
    val (alpha, circumference, radius) =
        calculateEarthMetrics(
            s1 = shadow1,
            h1 = height1,
            s2 = shadow2,
            h2 = height2,
            d = distanceBetweenCities,
        )

    // Output the estimated circumference and radius.
    println("\n*** Measuring Earth's Circumference and Radius ***\n")
    println("Angle (alpha): ${"%7.5f".format(alpha)} radian")
    println("Circumference: $circumference kilometers")
    println("Radius: $radius kilometers")
}
