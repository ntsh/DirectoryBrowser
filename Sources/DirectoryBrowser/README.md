# DirectoryBrowser

`DirectoryBrowser` is a SwiftUI view that presents a list of directories and allows users to navigate and manage the files inside them. It can also display and edit the app's `UserDefaults` values.

## Presenting the View

```swift
import DirectoryBrowser

struct ContentView: View {
    @State private var showBrowser = false

    var body: some View {
        Button("Browse") {
            showBrowser = true
        }
        .sheet(isPresented: $showBrowser) {
            DirectoryBrowser()
        }
    }
}
```

## Configuration Options

The initializer accepts two parameters:

- `urls`: Array of root directories to display. The default shows the app's Documents, Library and temporary directories.
- `confirmDelete`: When `true`, the UI asks for confirmation before deleting files.

```swift
DirectoryBrowser(urls: [.documentsDirectory], confirmDelete: false)
```
