//
//  Configuration+Helpers.swift
//  CanvasKit
//
//  Created by Dave Coleman on 2/5/2026.
//

import CoreUtilities

extension ToolConfiguration {
  static func containsTool(
    _ kind: CanvasToolKind,
    in tools: [any CanvasTool],
  ) -> Bool {
    firstIndex(of: kind, in: tools) != nil
  }

  static func firstIndex(
    of kind: CanvasToolKind,
    in tools: [any CanvasTool],
  ) -> Int? {
    tools.firstIndex { $0.kind == kind }
  }

  /// Whether the committed selection currently refers to a registered tool.
  public var isSelectionValid: Bool {
    Self.containsTool(selectedToolKind, in: tools)
  }

}

// MARK: - Equatability

extension ToolConfiguration: Equatable {

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.bindings == rhs.bindings && lhs.selectedToolKind == rhs.selectedToolKind
      && lhs.springLoadDelay == rhs.springLoadDelay
      && lhs.tools.elementsEqual(rhs.tools, by: Self.toolsAreEqual)
  }

  private static func toolsAreEqual(
    _ lhs: any CanvasTool,
    _ rhs: any CanvasTool,
  ) -> Bool {
    func compare<T: CanvasTool>(_ lhs: T, to rhs: any CanvasTool) -> Bool {
      guard let rhs = rhs as? T else { return false }
      return lhs == rhs
    }

    return compare(lhs, to: rhs)
  }

}

extension ToolConfiguration: CustomStringConvertible {
  public var description: String {
    DisplayString {
      Labeled("Tools", value: tools)
      Labeled("Bindings", value: bindings)
      Labeled("Selected Kind", value: selectedToolKind)
      Labeled("Spring Load Delay", value: springLoadDelay)
      Labeled("Is Selection Valid", value: isSelectionValid)
    }.text
  }
}
