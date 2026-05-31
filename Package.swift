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
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    .package(url: "https://github.com/dvclmn/ToolKit", .upToNextMinor(from: "0.1.0")),
    // Seems like the only way to temporarily use local version, rather than remote, for swift CLI?
//    .package(path: "../../ToolKit")
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
