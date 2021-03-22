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
    task(taskName + "Pom") {
        doLast {
            val parent = File(buildDir, "libs")
            if (!parent.exists()) parent.mkdirs()
            val file = File(parent, "${Maven.artifactId}-${version}.pom")
            if (file.exists()) file.delete()
            file.createNewFile()
            checkFileExists(file)
            val url = "https://github.com/kepocnhh/GitHubPackagesSample"
            val licenseUrl = "https://raw.githubusercontent.com/kepocnhh/GitHubPackagesSample/master/LICENSE"
            val text = MavenUtil.pom(
                modelVersion = "4.0.0",
                groupId = Maven.groupId,
                artifactId = Maven.artifactId,
                version = versionName,
                packaging = "jar",
                scmUrl = url,
                licenses = setOf("Apache License, Version 2.0" to licenseUrl),
                developers = setOf(Maven.developer),
                name = Maven.artifactId,
                description = "GitHub Packages sample...",
                url = url
            )
            file.writeText(text)
        }
    }
}
