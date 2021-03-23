import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.Enumeration;
import java.util.Properties;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Assertions;

class GitHubPackagesSampleTest {
    static private Properties properties = new Properties();
    static private String propertiesPath;

    @BeforeAll
    static public void beforeAll() {
        try (InputStream inputStream = GitHubPackagesSample.class.getResourceAsStream("/properties")) {
            properties.load(inputStream);
        } catch (Throwable t) {
            Assertions.fail(t);
        }
        try {
            propertiesPath = new File(
                GitHubPackagesSample.class
                .getResource("/properties")
                .toURI()).getAbsolutePath();
        } catch (Throwable t) {
            Assertions.fail(t);
        }
    }

    @BeforeEach
    public void beforeEach() {
        try {
            new File(propertiesPath).createNewFile();
        } catch (Throwable t) {
            Assertions.fail(t);
        }
        writeProperties(properties);
    }

    static private void writeProperties(Properties properties) {
        String result = "";
        Enumeration keys = properties.keys();
        while (keys.hasMoreElements()) {
            String key = (String) keys.nextElement();
            String value = (String) properties.get(key);
            result += "\n" + key + " " + value;
        }
        try (
            OutputStream outputStream = new FileOutputStream(
                new File(
                    GitHubPackagesSample.class.getResource("/properties").toURI()
                ),
                false
            )
        ) {
            outputStream.write(result.getBytes());
        } catch (Throwable t) {
            Assertions.fail(t);
        }
    }

    @Test
    public void getArtifactIdTest() {
        String expected = (String) properties.get("ARTIFACT_ID");
        String actual = GitHubPackagesSample.getArtifactId();
        Assertions.assertEquals(expected, actual);
    }

    @Test
    public void getArtifactIdNoPropertiesTest() {
        new File(propertiesPath).delete();
        try {
            GitHubPackagesSample.getArtifactId();
        } catch (IllegalStateException e) {
            return;
        }
        Assertions.fail();
    }

    @Test
    public void getArtifactIdPropertiesEmptyTest() {
        writeProperties(new Properties());
        try {
            GitHubPackagesSample.getArtifactId();
        } catch (IllegalStateException e) {
            return;
        }
        Assertions.fail();
    }

    @Test
    public void getArtifactIdEmptyTest() {
        Properties properties = new Properties();
        properties.setProperty("ARTIFACT_ID", "");
        writeProperties(properties);
        try {
            GitHubPackagesSample.getArtifactId();
        } catch (IllegalStateException e) {
            return;
        }
        Assertions.fail();
    }

    @Test
    public void getVersionTest() {
    	String expected = (String) properties.get("VERSION");
        String actual = GitHubPackagesSample.getVersion();
        Assertions.assertEquals(expected, actual);
    }

    @Test
    public void getVersionNoPropertiesTest() {
        new File(propertiesPath).delete();
        try {
            GitHubPackagesSample.getVersion();
        } catch (IllegalStateException e) {
            return;
        }
        Assertions.fail();
    }

    @Test
    public void getVersionPropertiesEmptyTest() {
        writeProperties(new Properties());
        try {
            GitHubPackagesSample.getVersion();
        } catch (IllegalStateException e) {
            return;
        }
        Assertions.fail();
    }

    @Test
    public void getVersionEmptyTest() {
        Properties properties = new Properties();
        properties.setProperty("VERSION", "");
        writeProperties(properties);
        try {
            GitHubPackagesSample.getVersion();
        } catch (IllegalStateException e) {
            return;
        }
        Assertions.fail();
    }

    @Test
    public void constructorTest() {
        Constructor[] constructors = GitHubPackagesSample.class.getDeclaredConstructors();
        Assertions.assertNotNull(constructors);
        Assertions.assertEquals(constructors.length, 1);
        Constructor constructor = constructors[0];
        Assertions.assertFalse(constructor.isAccessible());
        constructor.setAccessible(true);
        try {
            constructor.newInstance();
        } catch (InvocationTargetException e) {
            Throwable cause = e.getCause();
            Assertions.assertNotNull(cause);
            Assertions.assertTrue(cause instanceof IllegalStateException);
            return;
        } catch (Throwable t) {
            Assertions.fail(t);
        }
        Assertions.fail();
    }
}
