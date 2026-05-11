// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "CanvasKit",
  platforms: [
    .macOS("14.0")
  ],
  products: [
    .library(name: "CanvasKit", targets: ["CanvasKit"]),
  ],
  dependencies: [
    .package(url: "https://github.com/dvclmn/BasePrimitives", from: "0.1.0"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "CanvasKit",
      dependencies: [
        .product(name: "BasePrimitives", package: "BasePrimitives"),
        .product(name: "CoreUtilities", package: "BasePrimitives"),
      ]
    ),
    
    .testTarget(
      name: "CanvasKitTests",
      dependencies: ["CanvasKit"],
      exclude: ["CanvasKit.xctestplan"]
    ),
  ],
)
