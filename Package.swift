// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "CanvasKit",
  platforms: [
    .macOS("14.0")
  ],
  products: [
    .library(name: "CanvasKit", targets: ["CanvasKit"]),
    .library(name: "CanvasCore", targets: ["CanvasCore"]),
  ],
  dependencies: [
//    .package(url: "https://github.com/dvclmn/BasePrimitives", branch: "main"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "CanvasKit",
      dependencies: ["CanvasCore"],
    ),
    .target(
      name: "CanvasCore",
    ),
    .testTarget(
      name: "CanvasKitTests",
      dependencies: ["CanvasKit", "CanvasCore"],
    ),
  ],
)
