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
//    .package(url: "https://github.com/dvclmn/BaseHelpers", branch: "main"),
    .package(url: "https://github.com/dvclmn/InteractionKit", branch: "main"),
  ],
  targets: [
    .target(
      name: "CanvasKit",
      dependencies: [
//        .module(.basePrimitives),
//        .module(.enumMacros),
        .module(.interactionKit),
      ],
    ),
    .testTarget(
      name: "CanvasKitTests",
      dependencies: ["CanvasKit"],
    ),
  ],
)

extension Target.Dependency {

  static func module(_ dependency: BaseDependency) -> Self {
    .product(
      name: dependency.reference.0,
      package: dependency.reference.1 ?? dependency.reference.0,
    )
  }
}
extension String { static let baseHelpers = "BaseHelpers" }

enum BaseDependency {
//  case basePrimitives
//  case enumMacros
  case interactionKit

  var reference: (String, String?) {
    switch self {
//      case .basePrimitives: ("BasePrimitives", .baseHelpers)
//      case .enumMacros: ("BaseMacros", .baseHelpers)
      case .interactionKit: ("InteractionKit", nil)
    }
  }
}
