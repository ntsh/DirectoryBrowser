# DirectoryBrowser

Easily view, browse and manage files and data in app's directories. 

Useful during development and debugging.

## Features

- View, browse and delete list of all files and folders in app's temporary folder, Documents and Library folders.
- Preview thumbnails and content.
- Create folder, import from Photos and Files apps.

## Usage

Display DirectoryBrowser view from any SwiftUI view:

```
import DirectoryBrowser

// Display DirectoryBrowser()
.sheet(isPresented: $browse) {
    DirectoryBrowser()
}
```
