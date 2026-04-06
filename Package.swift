// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "CanvasKit",
  platforms: [
    .macOS("14.0")
  ],
  products: [
    .library(name: "CanvasKit", targets: ["CanvasKit"])
  ],
  dependencies: [
    .package(url: "https://github.com/dvclmn/InteractionKit", branch: "main"),
    .package(url: "https://github.com/dvclmn/BasePrimitives", branch: "main"),
  ],
  targets: [
    .target(
      name: "CanvasKit",
      dependencies: [
        "InteractionKit",
        "BasePrimitives",
//        .product(name: "InteractionKit", package: "InteractionKit"),
      ],
    ),
    .testTarget(
      name: "CanvasKitTests",
      dependencies: ["CanvasKit"],
    ),
  ],
)
