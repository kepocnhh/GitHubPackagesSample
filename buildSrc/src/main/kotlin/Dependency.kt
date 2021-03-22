object Group {
    const val jetbrains = "org.jetbrains"
    const val kotlin = "$jetbrains.kotlin"
    const val jupiter = "org.junit.jupiter"
}

data class Dependency(
    val group: String,
    val name: String,
    val version: String
) {
    companion object {
        val kotlinGradlePlugin = Dependency(
            group = Group.kotlin,
            name = "kotlin-gradle-plugin",
            version = Version.kotlin
        )
        val jupiterApi = Dependency(
            group = Group.jupiter,
            name = "junit-jupiter-api",
            version = Version.jupiter
        )
        val jupiterEngine = Dependency(
            group = Group.jupiter,
            name = "junit-jupiter-engine",
            version = Version.jupiter
        )
    }
}

data class Plugin(
    val name: String,
    val version: String
) {
    companion object {
        val jacoco = Plugin(
            name = "org.gradle.jacoco",
            version = Version.jacoco
        )
    }
}
