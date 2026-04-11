//
//  ToolDefaults.swift
//  CanvasKit
//
//  Created by Dave Coleman on 10/4/2026.
//

extension CanvasToolKind {
  public static let select = Self(rawValue: "select")
  public static let pan = Self(rawValue: "pan")
  public static let zoom = Self(rawValue: "zoom")
}

extension ToolBinding {

  /// A minimal set of sensible defaults:
  /// - Sticky shortcuts for Select (V), Pan (H), Zoom (Z)
  /// - Hold Space → spring-load Pan from any tool
  public static func defaultBindings() -> [ToolBinding] {
    [
      ToolBinding(.keyOnly("v"), target: .select, mode: .sticky),
      ToolBinding(.keyOnly("h"), target: .pan, mode: .sticky),
      ToolBinding(.keyOnly("z"), target: .zoom, mode: .sticky),
      ToolBinding(.keyOnly(.space), target: .pan, mode: .hold),
    ]
  }
}
