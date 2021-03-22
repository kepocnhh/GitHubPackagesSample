object MavenUtil {
    private const val MAVEN_APACHE_URL = "http://maven.apache.org"
    private fun mavenApacheUrlPom(modelVersion: String): String {
        return "$MAVEN_APACHE_URL/POM/$modelVersion"
    }

    fun pom(
        modelVersion: String,
        groupId: String,
        artifactId: String,
        version: String,
        packaging: String,
        scmUrl: String,
        licenses: Set<Pair<String, String>>,
        developers: Set<String>,
        name: String,
        description: String,
        url: String
    ): String {
        val mavenApacheUrlPom = mavenApacheUrlPom(modelVersion = modelVersion)
        val project = setOf(
            "xsi:schemaLocation" to "$mavenApacheUrlPom $MAVEN_APACHE_URL/xsd/maven-$modelVersion.xsd",
            "xmlns" to mavenApacheUrlPom,
            "xmlns:xsi" to "http://www.w3.org/2001/XMLSchema-instance"
        ).joinToString(separator = " ") { (key, value) ->
            "$key=\"$value\""
        }
        val scm = "<scm><url>$scmUrl</url></scm>"
        val l = licenses.joinToString(
            prefix = "<licenses>",
            separator = "",
            postfix = "</licenses>"
        ) { (name, url) ->
        	"<license><name>$name</name><url>$url</url></license>"
        }
        val d = developers.joinToString(
            prefix = "<developers>",
            separator = "",
            postfix = "</developers>"
        ) { "<developer><name>$it</name></developer>" }
        return mapOf(
            "modelVersion" to modelVersion,
            "groupId" to groupId,
            "artifactId" to artifactId,
            "version" to version,
            "packaging" to packaging,
            "name" to name,
            "description" to description,
            "url" to url
        ).toList().joinToString(
            prefix = "<project $project>",
            separator = "",
            postfix = "$scm$l$d</project>"
        ) { (key, value) ->
            "<$key>$value</$key>"
        }
    }
}
