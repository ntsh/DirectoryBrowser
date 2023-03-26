# DirectoryBrowser

Swift package to easily view, browse and manage files and data in your iOS app's directories. 

Useful during development and debugging.

## Features

- View, browse and delete list of all files and folders in app's temporary folder, Documents and Library folders.
- Preview thumbnails and content.
- Create folder, import from Photos and Files apps.

## Installation

Swift Package Manager:

```
dependencies: [
    .package(url: "https://github.com/ntsh/DirectoryBrowser", .upToNextMajor(from: "0.1.0"))
]
```

## Usage

Display DirectoryBrowser view from any SwiftUI view:

```
import DirectoryBrowser

// Display DirectoryBrowser()
.sheet(isPresented: $browse) {
    DirectoryBrowser()
}
```
