# DirectoryBrowser

Swift package to easily view, browse and manage files and data in your iOS app's directories. 

Useful during development and debugging.

## Features

- View, browse and delete list of all files and folders in app's temporary folder, Documents and Library folders.
- Preview thumbnails and content.
- Create folder, import from Photos and Files apps.
- Preview and edit UserDefaults values.

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

## Demo

![DirectoryBrowserDemo](https://user-images.githubusercontent.com/2085458/228767225-6ef60c17-68ce-4bf3-859f-86d1c6b192a4.gif)

## Libraries

### DirectoryBrowser

The `DirectoryBrowser` library provides the UI components to easily view and manage files in your app's directories.

### DirectoryManager

The `DirectoryManager` library is the core of the package, providing the necessary functionality to browse and manage files via code.

## API Documentation

- [DirectoryBrowser](Sources/DirectoryBrowser/README.md)
- [DirectoryManager](Sources/DirectoryManager/README.md)
