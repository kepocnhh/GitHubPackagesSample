
buildscript {
    repositories.jcenter()
    dependencies(Dependency.kotlinGradlePlugin)
}

plugins {
    apply(Plugin.jacoco)
}

repositories.jcenter()

task<Delete>("clean") {
    delete = setOf(rootProject.buildDir, "buildSrc/build")
}

task("artifactId") {
	doLast {
		println(Maven.artifactId)
	}
}

task("verifyLicense") {
    doLast {
        val file = File(rootDir, "LICENSE")
        val text = file.requireFilledText()
        setOf(Maven.developer).forEach {
            check(text.contains(it)) {
                "File by path ${file.absolutePath} must contains\nvvv\n\n$it\n\n^^^!"
            }
        }
        // todo
    }
}

task("verifyReadme") {
    doLast {
        val file = File(rootDir, "README.md")
        val text = file.requireFilledText()
        val dependencyMaven = """
            <dependency>
                <groupId>${Maven.groupId}</groupId>
                <artifactId>${Maven.artifactId}</artifactId>
                <version>${Version.name}</version>
            </dependency>
        """.trimIndent()
        setOf(dependencyMaven).forEach {
            check(text.contains(it)) {
                "File by path ${file.absolutePath} must contains\nvvv\n\n$it\n\n^^^!"
            }
        }
        val lines = text.split(SystemUtil.newLine)
        val versionBadge = MarkdownUtil.image(
            text = "version",
            url = BadgeUtil.url(
                label = "version",
                message = Version.name,
                color = "2962ff"
            )
        )
        setOf(versionBadge).forEach {
            check(lines.contains(it)) {
                "File by path ${file.absolutePath} must contains line:\n\n$it\n\n^^^!"
            }
        }
    }
}

task("verifyService") {
    doLast {
        val forbiddenFileNames = setOf(".DS_Store")
        rootDir.onFileRecurse {
            if (!it.isDirectory) {
                check(!forbiddenFileNames.contains(it.name)) {
                    "File by path ${it.absolutePath} must not be exists!"
                }
            }
        }
    }
}
