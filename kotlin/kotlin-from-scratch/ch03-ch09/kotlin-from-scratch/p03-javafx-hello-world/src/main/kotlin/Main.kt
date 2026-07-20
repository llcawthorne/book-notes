import javafx.application.Application
import javafx.geometry.Pos
import javafx.stage.Stage
import javafx.scene.Scene
import javafx.scene.layout.VBox
import javafx.scene.text.Font
import javafx.scene.text.Text

class HelloWorld : Application() {
    override fun start(primaryStage: Stage) {
        // Custom to this project
        val text = Text("Hello, world!")
        text.font = Font.font("Verdana", 20.0)

        val vbx = VBox(text)
        vbx.alignment = Pos.CENTER

        // Boiler plate to start the Stage
        val scene = Scene(vbx, 300.0, 300.0)
        primaryStage.title = "Primary Stage"
        primaryStage.scene = scene
        primaryStage.show()
    }
}

fun main() {
    Application.launch(HelloWorld::class.java)
}
