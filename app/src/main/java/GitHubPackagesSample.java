import java.io.InputStream;
import java.util.Properties;

/**
 * GitHubPackagesSample class, please see the <a href="https://github.com/kepocnhh/GitHubPackagesSample">github</a>
 * @author Stanley Wintergreen
 * @version 1
 * @since 0.0.7
*/
public class GitHubPackagesSample {
    static public String getVersion() {
    	String result;
        Object version;
    	try (InputStream inputStream = GitHubPackagesSample.class.getResourceAsStream("/properties")) {
	        Properties properties = new Properties();
	        properties.load(inputStream);
	        version = properties.get("VERSION");
    	} catch (Throwable t) {
    		throw new IllegalStateException("Get version error!", t);
    	}
        if (version == null) throw new IllegalStateException("Version null!");
        result = (String) version;
        if (result.isEmpty()) throw new IllegalStateException("Version is empty!");
        return result;
    }

    static public String getArtifactId() {
        String result;
        Object actual;
        try (InputStream inputStream = GitHubPackagesSample.class.getResourceAsStream("/properties")) {
            Properties properties = new Properties();
            properties.load(inputStream);
            actual = properties.get("ARTIFACT_ID");
        } catch (Throwable t) {
            throw new IllegalStateException("Get artifact error!", t);
        }
        if (actual == null) throw new IllegalStateException("Artifact null!");
        result = (String) actual;
        if (result.isEmpty()) throw new IllegalStateException("Artifact is empty!");
        return result;
    }

    private GitHubPackagesSample() {
    	throw new IllegalStateException("Impossible!");
    }
}
