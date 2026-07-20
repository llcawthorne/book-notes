import javafx.animation.Animation
import javafx.animation.KeyFrame
import javafx.animation.Timeline
import javafx.application.Application
import javafx.scene.Scene
import javafx.scene.layout.Pane
import javafx.scene.paint.Color
import javafx.scene.shape.Circle
import javafx.stage.Stage
import javafx.util.Duration

class BouncingBall : Application() {
    override fun start(primaryStage: Stage) {
        // Custom to this project
        primaryStage.title = "Bouncing Red Ball"

        // Create a circle
        val redBall = Circle(250.0, 200.0, 30.0, Color.RED)

        val root = Pane(redBall)
        val scene = Scene(root, 500.0, 400.0)
        primaryStage.scene = scene
        primaryStage.show()

        bouncyBall(redBall, scene)
    }

    fun bouncyBall(
        redBall: Circle,
        scene: Scene,
    ) {
        // displacement parameters
        var dx = 2
        var dy = 2

        // Timeline-KeyFrame with ActionEvent
        val tl = Timeline()
        val moveBall =
            KeyFrame(
                Duration.seconds(0.015),
                {
                    // Get min/max boudary coordinates.
                    val xMin = redBall.boundsInParent.minX
                    val xMax = redBall.boundsInParent.maxX
                    val yMin = redBall.boundsInParent.minY
                    val yMax = redBall.boundsInParent.maxY

                    // Change direction if boundary is hit/crossed.
                    if (xMin < 0 || xMax > scene.width) {
                        dx = -dx
                    }
                    if (yMin < 0 || yMax > scene.height) {
                        dy = -dy
                    }
                    // Continue to move.
                    redBall.translateX += dx
                    redBall.translateY += dy
                },
            )

        with(tl) {
            keyFrames.add(moveBall)
            cycleCount = Animation.INDEFINITE
            play()
        }
    }
}

fun main() {
    Application.launch(BouncingBall::class.java)
}