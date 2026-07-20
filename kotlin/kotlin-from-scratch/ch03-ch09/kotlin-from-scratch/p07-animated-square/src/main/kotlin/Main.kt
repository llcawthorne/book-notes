import javafx.animation.Transition
import javafx.animation.TranslateTransition
import javafx.application.Application
import javafx.scene.Scene
import javafx.scene.layout.Pane
import javafx.scene.paint.Color
import javafx.scene.shape.Rectangle
import javafx.stage.Stage
import javafx.util.Duration

class TransitionExample : Application() {
    override fun start(primaryStage: Stage) {
        // Custom to this project
        primaryStage.title = "Transition Example"

        // Create a square
        val square = Rectangle(50.0, 50.0, Color.RED)
        square.y = 100.0
        val pane = Pane(square)

        // Create a scene and show the stage.
        val scene = Scene(pane, 300.0, 300.0)
        primaryStage.scene = scene
        primaryStage.show()

        // Create a TranslateTransition class instance
        // and set its properties.
        val transition = TranslateTransition(Duration.seconds(2.0), square)

        with(transition) {
            fromX = 0.0
            toX = pane.width - square.width
            cycleCount = Transition.INDEFINITE
            isAutoReverse = true
            play()
        }
    }
}

fun main() {
    Application.launch(TransitionExample::class.java)
}