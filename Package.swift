// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "CanvasKit",
  platforms: [
    .macOS("14.0")
  ],
  products: [
    .library(name: "CanvasKit", targets: ["CanvasKit"])
    //    .library(name: "DesignKit", targets: ["DesignKit"] )
  ],
  dependencies: [
    .package(url: "https://github.com/dvclmn/BaseHelpers", branch: "main")
  ],
  targets: [
    .target(
      name: "CanvasKit",
      dependencies: [
        .product(name: "SharedHelpers", package: "BaseHelpers"),
        .product(name: "BaseMacros", package: "BaseHelpers"),
        .product(name: "GestureKit", package: "BaseHelpers"),
        .product(name: "BaseUI", package: "BaseHelpers"),

      ]
    ),
    .testTarget(
      name: "CanvasKitTests",
      dependencies: ["CanvasKit"]
    ),
  ]
)
