

class Duck(
    val height: Int? = null,
) {
    fun quack() {
        println("Quack! Quack!")
    }
}

class MyDucks(
    var myDucks: Array<Duck?>,
) {
    fun quack() {
        for (duck in myDucks) {
            duck?.let {
                // We could've used duck?.quack()
                it.quack()
            }
        }
    }
}

fun totalDuckHeight(): Int {
    var h: Int = 0 // totalDuckHeight returns an Int, not an Int?
    for (duck in myDucks) {
        h += duck?.height ?: 0 // use 0 for null Duck or null height
    }
    return h
}
