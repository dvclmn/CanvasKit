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
    .package(url: "https://github.com/dvclmn/BaseHelpers", branch: "main")
  ],
  targets: [
    .target(
      name: "CanvasKit",
      dependencies: [
        .module(.basePrimitives),
        .module(.enumMacros),
//        .product(name: "SharedHelpers", package: "BaseHelpers"),
//        .product(name: "BaseMacros", package: "BaseHelpers"),
//        .product(name: "GestureKit", package: "BaseHelpers"),
//        .product(name: "BaseUI", package: "BaseHelpers"),

      ]
    ),
    .testTarget(
      name: "CanvasKitTests",
      dependencies: ["CanvasKit"]
    ),
  ]
)

extension Target.Dependency {
//  static var demosCore: Self {
//    .target(name: "DemosCore")
//  }
  static func module(_ dependency: BaseDependency) -> Self {
    .product(
      name: dependency.reference.0,
      package: dependency.reference.1 ?? dependency.reference.0
    )
  }
}
extension String { static let baseHelpers = "BaseHelpers" }

enum BaseDependency {
  /// BaseHelpers
  //  case gestureKit
  case basePrimitives
  case enumMacros
  //  case sharedHelpers  // + Wrecktangle
//  case baseUI
  //  case layoutKit
//  case graphicsKit
  
  /// Forwards-only
//  case toolKit
  //  case coreTools
  
  /// Third party
//  case casePaths
//  case sharing
//  case metaCodable
  
  var reference: (String, String?) {
    switch self {
        
        //      case .gestureKit: ("GestureKit", .baseHelpers)
      case .basePrimitives: ("BasePrimitives", .baseHelpers)
      case .enumMacros: ("BaseMacros", .baseHelpers)
        //      case .sharedHelpers: ("SharedHelpers", .baseHelpers)
//      case .baseUI: ("BaseUI", .baseHelpers)
        //      case .layoutKit: ("LayoutKit", .baseHelpers)
//      case .graphicsKit: ("GraphicsKit", .baseHelpers)
        
        //      case .coreTools: ("CoreTools", .baseHelpers)
//      case .toolKit: ("ToolKit", .baseHelpers)
        
        /// Third party
//      case .casePaths: ("CasePaths", "swift-case-paths")
//      case .sharing: ("Sharing", "swift-sharing")
//      case .metaCodable: ("MetaCodable", nil)
        
    }
  }
}
