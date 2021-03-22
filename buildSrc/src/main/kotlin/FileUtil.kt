import java.io.File

fun File.onFileRecurse(action: (File) -> Unit) {
    action(this)
    if (isDirectory) {
        listFiles()?.forEach {
            it.onFileRecurse(action)
        }
    }
}
