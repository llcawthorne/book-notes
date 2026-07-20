import javafx.animation.KeyFrame
import javafx.animation.KeyValue
import javafx.animation.Timeline
import javafx.application.Application
import javafx.scene.Scene
import javafx.scene.layout.StackPane
import javafx.scene.paint.Color
import javafx.scene.shape.Circle
import javafx.stage.Stage
import javafx.util.Duration

class KeyframeAnimationExample : Application() {
    override fun start(primaryStage: Stage) {
        // Custom to this project
        primaryStage.title = "Animation Example: A Growing and Shrinking Circle"

        // Create a circle
        val circle = Circle(50.0, Color.BLUE)

        val root = StackPane(circle) // autocenters child node
        val scene = Scene(root, 600.0, 600.0)
        primaryStage.scene = scene
        primaryStage.show()

        // Create a Timeline for the animation.
        val timeline = Timeline()
        // Define keyframes
        val startFrame =
            KeyFrame(
                Duration.ZERO,
                KeyValue(circle.radiusProperty(), 50.0),
            )
        val endFrame =
            KeyFrame(
                Duration.seconds(5.0),
                KeyValue(circle.radiusProperty(), 250.0),
            )
        // Add keyframes to the timeline.
        timeline.keyFrames.addAll(startFrame, endFrame)

        // Set and play the timeline
        with(timeline) {
            cycleCount = Timeline.INDEFINITE
            isAutoReverse = true
            play()
        }
    }
}

fun main() {
    Application.launch(KeyframeAnimationExample::class.java)
}

