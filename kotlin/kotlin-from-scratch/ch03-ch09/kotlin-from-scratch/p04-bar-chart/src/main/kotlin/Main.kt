import javafx.application.Application
import javafx.geometry.Pos
import javafx.geometry.Side
import javafx.scene.Scene
import javafx.scene.chart.BarChart
import javafx.scene.chart.CategoryAxis
import javafx.scene.chart.NumberAxis
import javafx.scene.chart.XYChart
import javafx.scene.layout.VBox
import javafx.scene.text.Font
import javafx.scene.text.Text
import javafx.stage.Stage

class BarChartExample : Application() {
    override fun start(primaryStage: Stage) {
        // Custom to this project

        // Create XYAxis Objects
        val xAxis = CategoryAxis()
        val yAxis = NumberAxis()
        xAxis.label = "Months"
        yAxis.label = "Sales in thousands of dollars"

        // Create BarChart object and set its properties.
        val barChart = BarChart(xAxis, yAxis)
        barChart.title = "Monthly Sales"
        barChart.legendSide = Side.TOP

        // Create Series, populate with data, and assign to chart.
        val dataSeries = XYChart.Series<String, Number>()
        dataSeries.name = "Q1 Data for ABC & Co."
        getData(dataSeries)
        barChart.data.add(dataSeries)

        // Boiler plate to start the Stage
        val scene = Scene(barChart, 400.0, 400.0)
        primaryStage.title = "Bar Chart Example"
        primaryStage.scene = scene
        primaryStage.show()
    }
}

fun getData(dataSeries: XYChart.Series<String, Number>) {
    dataSeries.data.addAll(
        XYChart.Data("Jan", 150),
        XYChart.Data("Feb", 100),
        XYChart.Data("Mar", 225),
    )
}

fun main() {
    Application.launch(BarChartExample::class.java)
}
