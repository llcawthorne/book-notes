plugins {
    kotlin("jvm") version "2.3.21" apply false
    id("org.openjfx.javafxplugin") version "0.1.0" apply false
}

group = "io.github.llcawthorne"
version = "1.0-SNAPSHOT"

subprojects {
    repositories {
        mavenCentral()
    }
}