import javafx.application.Application
import javafx.scene.Scene
import javafx.scene.canvas.Canvas
import javafx.scene.canvas.GraphicsContext
import javafx.scene.layout.Pane
import javafx.scene.paint.Color
import javafx.stage.Stage
import kotlin.math.cos
import kotlin.math.sin

class MultiTurnSpiral : Application() {
    override fun start(primaryStage: Stage) {
        // Custom to this project
        primaryStage.title = "Multi-Turn Spiral"

        // Create a canvas and set it graphics context.
        val canvas = Canvas(600.0, 600.0)
        val gc = canvas.graphicsContext2D

        // Boiler plate to start the Stage
        primaryStage.scene = Scene(Pane(canvas))
        primaryStage.show()

        drawMultiTurnSpiral(gc, canvas.width, canvas.height)
    }
}

fun drawMultiTurnSpiral(
    gc: GraphicsContext,
    width: Double,
    height: Double,
) {
    // Set key parameters for the spiral.
    val numCircles = 70
    val turns = 2.0
    val maxAngle = 360.0 * turns
    // rotation in degrees per step
    val rotationStep = (maxAngle / numCircles)

    // Ensure the circles stay inside the canvas boundaries
    val maxRadius = minOf(width, height) / 10.0
    // Set the amplification factor
    val spacingFactor = 2.0
    val radiusStep = (maxRadius / numCircles) * spacingFactor

    printParams(gc, radiusStep, numCircles)

    for (i in 0..<numCircles) {
        val angle = i * rotationStep
        val radius = i * radiusStep

        val x = (width / 2.0) + radius * cos(Math.toRadians(angle))
        val y = (height / 2.0) + radius * sin(Math.toRadians(angle))

        drawCircle(gc, x, y, radius)
    }
}

fun printParams(gc: GraphicsContext, radiusStep: Double, numCircles: Int) {
    val msg1 = "Base radius: " + "%.4f".format(radiusStep) + " pixels"
    val msg2 = "Number of shapes (circles): $numCircles"
    gc.fillText(msg1, 25.0, 555.0)
    gc.fillText(msg2, 25.0, 575.0)
}

fun drawCircle(
    gc: GraphicsContext,
    x: Double, y: Double, radius: Double
) {
    // Set draw parameters
    val topLeftX = x - radius
    val topLeftY = y - radius
    val pointSize = 8.0

    with (gc) {
        lineWidth = 2.0
        stroke = Color.LIGHTBLUE
        fill = Color.RED
        fillOval(x - pointSize / 2, y - pointSize /2, pointSize, pointSize)
        strokeOval(topLeftX, topLeftY, radius * 2, radius * 2)
    }
}

fun main() {
    Application.launch(MultiTurnSpiral::class.java)
}
