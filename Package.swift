// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DirectoryBrowser",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library( name: "DirectoryBrowser", targets: ["DirectoryBrowser"]),
        .library(name: "DirectoryManager", targets: ["DirectoryManager"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/ntsh/FilePreviews.git", .upToNextMajor(from: "0.2.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DirectoryBrowser",
            dependencies: ["FilePreviews", "DirectoryManager"]),
        .target(name: "DirectoryManager"),
        .testTarget(
            name: "DirectoryBrowserTests",
            dependencies: ["DirectoryBrowser"]),
    ]
)
