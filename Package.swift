// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RotatingCamera",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RotatingCamera",
            targets: ["RotatingCamera"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/jdg/MBProgressHUD.git", .upToNextMajor(from: "1.2.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RotatingCamera", dependencies: ["SnapKit", "MBProgressHUD"]),
        .testTarget(
            name: "RotatingCameraTests",
            dependencies: ["RotatingCamera"]),
    ]
)
