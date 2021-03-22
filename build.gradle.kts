
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
