plugins {
    kotlin("jvm")
    application
//    id("org.openjfx.javafxplugin")
}

dependencies {
    testImplementation(kotlin("test"))
}

kotlin {
    jvmToolchain(21)
}

application {
    mainClass.set("MainKt")
}

// javafx {
//    version = "21"
//    modules = listOf("javafx.controls", "javafx.fxml")
// }

tasks.named<JavaExec>("run") {
    standardInput = System.`in`
}

tasks.test {
    useJUnitPlatform()
}

