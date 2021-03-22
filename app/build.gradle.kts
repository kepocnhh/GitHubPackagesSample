plugins {
    apply(Plugin.jacoco)
}
apply(plugin = "java") // todo

repositories.jcenter()

dependencies(
    "testImplementation" to setOf(Dependency.jupiterApi),
    "testRuntimeOnly" to setOf(Dependency.jupiterEngine)
)

tasks.withType<Test> {
    useJUnitPlatform()
}

version = Version.name

val processResourcesTask = tasks.getByName<ProcessResources>("processResources")
val afterProcessResourcesTask = task("afterProcessResources") {
    doLast {
        if (!processResourcesTask.destinationDir.exists()) {
            processResourcesTask.destinationDir.mkdirs()
        }
        val text = """
            VERSION $version
        """.trimIndent()
        File(processResourcesTask.destinationDir, "properties").writeText(text)
    }
}

processResourcesTask.finalizedBy(afterProcessResourcesTask)

setOf(
    "debug",
    "release",
    "snapshot"
).forEach { type ->
    val buildName = "GitHubPackagesSample"
    val versionName = when (type) {
        "debug" -> "$version-$type"
        "release" -> version.toString()
        "snapshot" -> "$version-SNAPSHOT"
        else -> error("Type \"$type\" not supported!")
    }
    task("version" + type.capitalize() + "Name") {
        doLast {
            println(versionName)
        }
    }
    val taskName = "assemble" + type.capitalize()
    task<Jar>(taskName) {
        archiveBaseName.set(buildName)
        archiveVersion.set(versionName)
    }
    task<Jar>(taskName + "Source") {
        archiveBaseName.set(buildName)
        archiveVersion.set(versionName)
        archiveClassifier.set("sources")
        from(sourceSet("main").allSource)
    }
    task<Javadoc>(taskName + "Documentation") {
        source = sourceSet("main").allJava
    }
    task<Jar>(taskName + "Javadoc") {
        archiveBaseName.set(buildName)
        archiveVersion.set(versionName)
        archiveClassifier.set("javadoc")
        from(sourceSet("main").allSource)
    }
    // todo pom
}
