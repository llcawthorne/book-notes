class Song(val title: String, val artist:String) {
    fun play() {
        println("Playing the song $title by $artist")
    }

    fun stop() {
        println("Stopped playing $title")
    }
}

fun main() {
    val song1 = Song("The Mesopotamians", "They Might Be Giants")
    val song2 = Song("Going Underground", "The Jam")
    val song3 = Song("Make Me Smile", "Steve Harley")
    
    song2.play()
    song2.stop()
    song3.play()
}