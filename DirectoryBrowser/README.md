# DirectoryBrowser

Easily view, browse and manage documents directory content. 

Useful during development and debugging.

## Usage

Display DirectoryBrowser view from any SwiftUI view:

```
.sheet(isPresented: $browse) {
    DirectoryBrowser(documentsStore: DocumentsStore())
}
```
