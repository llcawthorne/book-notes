import javafx.application.Application
import javafx.scene.Scene
import javafx.scene.canvas.Canvas
import javafx.scene.canvas.GraphicsContext
import javafx.scene.layout.Pane
import javafx.scene.paint.Color
import javafx.scene.shape.ArcType
import javafx.scene.text.Font
import javafx.stage.Stage

/*
 * Fibonacci Sequence
 *
 * 1. Set the first two numbers in the sequence. By convention, these are
 *    usually 0 and 1 rather than 1 and 1.
 * 2. Add the first two numbers to get the third number in the sequence.
 * 3. Generate the next number by adding the two preceding numbers. This
 *    step can be mathematic expressed as $F_{n} = F_{n-1} + F_{n-2}$ where
 *    $n \ge 2$.
 * 4. Repeat step 3 until the stopping condition is met.
 *
 * The *golden ratio* is approximately 1.61803398875 and is denoted by the
 * Greek letter $\phi$. The ratio between each successive pair of Fibonacci
 * numbers as the sequence continues approaches the golden ratio.
 *
 * The *Fibonacci spiral* is a geometric pattern derived from the Fibonacci
 * sequence. It's crated by drawing a series of quarter circles inside
 * squares that are based on the numbers in the Fibonacci sequence.
 * To draw a spiral:
 *
 * 1. Draw a small square with side length of 1.
 * 2. Draw another square of side length 1 adjacent to the first square,
 *    sharing a side.
 * 3. Draw a third square of side length 2 adjacent to the second square,
 *    sharing a side.
 * 4. Draw a fourth square of side length 3 adjacent to the third square,
 *    sharing a side.
 * 5. Continue this process, drawing squares with side lengths equal to the
 *    sum of the two preceding squares, adjacent to the last drawn square,
 *    sharing a side.
 * 6. Draw a quarter circle inside each of the squares, connecting the
 *    opposite corners of each square. The quarter circles will form a smooth
 *    curve: the Fibonacci spiral.
 *
 */

// number of Fibonacci numbers in the list
val N = 9
val fibs = mutableListOf<Int>()

// canvas-related parameters
val canvasW = 1000.0
val canvasH = 750.0

// Scaling parameters: adjust as needed
val xOffset = 150
val yOffset = 50
val amplify = 25.0 // we don't want to start with a 1 pixel square: 1 * 25.0

class FibonacciSpiral : Application() {
    override fun start(stage: Stage) {
        val root = Pane()
        val canvas = Canvas(canvasW, canvasH)
        val gc = canvas.graphicsContext2D
        // translate here shifts the initial position of the origin from
        // the top left to a bit offset from the center.
        gc.translate(
            canvas.width / 2 + xOffset,
            canvas.height / 2 + yOffset,
        )
        root.children.add(canvas)

        val scene1 = Scene(root, canvasW, canvasH)
        scene1.fill = Color.WHITE
        with(stage) {
            title = "Fibonacci Spiral"
            scene = scene1
            show()
        }

        // code for Fibonacci sequence and spiral
        generateFibonacciNumbers()
        drawFibonacciSpiral(gc)
        printFibonacciSequenceAndRatios()
    }
}

fun main() {
    Application.launch(FibonacciSpiral::class.java)
}

fun generateFibonacciNumbers() {
    fibs.add(0)
    fibs.add(1)

    for (i in 2 until N) {
        fibs.add(fibs[i - 1] + fibs[i - 2])
    }
}

fun drawFibonacciSpiral(gc: GraphicsContext) {
    for (i in 1 until N) {
        val side = fibs[i] * amplify
        with(gc) {
            // We draw every square from 0, 0 because we keep translating the
            // origin by the length of the sides
            strokeRect(0.0, 0.0, side, side)
            drawText(i, gc, side)
            drawArc(gc, side)
            // Move to the opposite corner by adding
            // side to both x- and y-coordinates.
            translate(side, side)
            // Rotate the axes counterclockwise.
            rotate(-90.0)
        }
    }
}

fun drawText(
    i: Int,
    gc: GraphicsContext,
    side: Double,
) {
    gc.fill = Color.BLACK
    with(gc) {
        font =
            when {
                i <= 2 -> Font.font(12.0)
                else -> Font.font(24.0)
            }
        fillText(fibs[i].toString(), side / 2, side / 2)
    }
}

fun drawArc(
    gc: GraphicsContext,
    side: Double,
) {
    val x = 0.0
    val y = -side
    with(gc) {
        lineWidth = 3.0
        strokeArc(
            x,
            y,
            2 * side,
            2 * side,
            -90.0,
            -90.0,
            ArcType.OPEN,
        )
    }
}

private fun printFibonacciSequenceAndRatios() {
    println("\n*** Fibonacci sequence and ratios ***\n")
    println("Length of Fibonacci sequence=${fibs.size}")
    println("Generated sequence:")
    println(fibs)
    println("\nRatio F(n+1)/F(n) [starting from (1,1) pair]:")
    for (i in 2 until fibs.size) {
        println(
            "%5d".format(fibs[i-1]) +
            "%5d".format(fibs[i]) +
            "%12.6f".format(fibs[i].toDouble()/fibs[i-1])
        )
    }
}
