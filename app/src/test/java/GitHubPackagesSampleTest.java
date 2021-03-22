import java.io.InputStream;
import java.util.Properties;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Assertions;

class GitHubPackagesSampleTest {
    @Test
    public void getVersionTest() {
    	String expected;
    	try (InputStream inputStream = GitHubPackagesSampleTest.class.getResourceAsStream("/properties")) {
	        Properties properties = new Properties();
	        properties.load(inputStream);
	        Object version = properties.get("VERSION");
	        if (version == null) throw new IllegalStateException("Version null!");
	        if (!(version instanceof String)) throw new IllegalStateException("Version is not java.lang.String!");
	        expected = (String) version;
	        if (expected.isEmpty()) throw new IllegalStateException("Version is empty!");
    	} catch (Throwable t) {
    		throw new IllegalStateException("Get version error!", t);
    	}
        String actual = GitHubPackagesSample.getVersion();
        Assertions.assertEquals(expected, actual);
    }
}
