import javafx.application.Application
import javafx.geometry.Side
import javafx.scene.Scene
import javafx.scene.chart.LineChart
import javafx.scene.chart.NumberAxis
import javafx.scene.chart.XYChart
import javafx.stage.Stage

class LineChartExample : Application() {
    override fun start(primaryStage: Stage) {
        // Custom to this project
        primaryStage.title = "Multiseries Line Chart Example"

        // Create XYAxis Objects
        val xAxis = NumberAxis()
        val yAxis = NumberAxis()
        xAxis.label = "Age"
        yAxis.label = "Height (inches)"

        // Adjust tick interval and lower/upper bounds.
        xAxis.isAutoRanging = false
        xAxis.tickUnit = 5.0 // custom tick interval
        xAxis.lowerBound = 0.0
        xAxis.upperBound = 35.0

        yAxis.isAutoRanging = false
        yAxis.lowerBound = 20.0
        yAxis.upperBound = 75.0

        // Create LineChart object and set its properties.
        val lineChart = LineChart(xAxis, yAxis)
        lineChart.title = "Average Heights at Different Ages"
        lineChart.legendSide = Side.TOP

        // Create Series, populate with data, and assign to chart.
        val maleData = XYChart.Series<Number, Number>()
        maleData.name = "Male"
        getMaleData(maleData)
        val femaleData = XYChart.Series<Number, Number>()
        femaleData.name = "Female"
        getFemaleData(femaleData)

        lineChart.data.addAll(maleData, femaleData)

        // Boiler plate to start the Stage
        val scene = Scene(lineChart, 800.0, 800.0)
        primaryStage.scene = scene
        primaryStage.show()
    }
}

fun getMaleData(dataSeries: XYChart.Series<Number, Number>) {
    dataSeries.data.addAll(
        XYChart.Data(5, 38.0),
        XYChart.Data(10, 50.0),
        XYChart.Data(15, 62.0),
        XYChart.Data(20, 68.0),
        XYChart.Data(30, 69.0),
    )
}

fun getFemaleData(dataSeries: XYChart.Series<Number, Number>) {
    dataSeries.data.addAll(
        XYChart.Data(5, 36.0),
        XYChart.Data(10, 48.0),
        XYChart.Data(15, 60.0),
        XYChart.Data(20, 64.0),
        XYChart.Data(30, 65.0),
    )
}
fun main() {
    Application.launch(LineChartExample::class.java)
}
