import java.io.File
import java.nio.charset.Charset

fun checkFileExists(file: File) {
    check(file.exists()) { "File by path \"${file.absolutePath}\" must be exists!" }
}

fun File.requireText(charset: Charset = Charsets.UTF_8): String {
    checkFileExists(this)
    return readText(charset)
}

fun File.requireFilledText(charset: Charset = Charsets.UTF_8): String {
    val text = requireText(charset)
    check(text.isNotEmpty()) { "File by path $absolutePath must be not empty!" }
    return text
}
