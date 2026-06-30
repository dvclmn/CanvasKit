// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "CanvasKit",
  platforms: [
    .macOS(.v14),
  ],
  products: [
    .library(name: "CanvasKit", targets: ["CanvasKit"])
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.0.0"),
    .package(url: "https://github.com/dvclmn/ToolKit", .upToNextMinor(from: "0.2.0")),
  ],
  targets: [
    .target(
      name: "CanvasKit",
      dependencies: [
        .product(name: "CoreTools", package: "ToolKit"),
        .product(name: "ViewTools", package: "ToolKit"),
      ],
    ),

    .testTarget(
      name: "CanvasKitTests",
      dependencies: ["CanvasKit"],
      exclude: ["CanvasKit.xctestplan"],
    ),
  ],
)
