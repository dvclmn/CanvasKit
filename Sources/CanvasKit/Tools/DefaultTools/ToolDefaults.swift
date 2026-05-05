//
//  ToolDefaults.swift
//  CanvasKit
//
//  Created by Dave Coleman on 10/4/2026.
//

extension CanvasToolKind {
  public static let select = Self("select")
  public static let pan = Self("pan")
  public static let zoom = Self("zoom")
}

extension ToolBinding {
  
  // TODO: Add binding for "hold Command = Activate a Select mode/tool"

  /// A minimal set of binding defaults:
  /// - Sticky shortcuts for Select (V), Pan (H), Zoom (Z)
  /// - Hold Space to immediately spring-load Pan from any committed tool
  public static func defaultBindings() -> [ToolBinding] {
    [
      ToolBinding(.keyOnly("v"), target: .select, mode: .sticky),
      ToolBinding(.keyOnly("h"), target: .pan, mode: .sticky),
      ToolBinding(.keyOnly("z"), target: .zoom, mode: .sticky),
      ToolBinding(.keyOnly(.space), target: .pan, mode: .hold),
    ]
  }
}
