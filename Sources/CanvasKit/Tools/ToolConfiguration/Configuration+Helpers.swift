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

  /// Whether the committed/base tool kind currently refers to a registered tool.
  public var isCommittedToolKindValid: Bool {
    Self.containsTool(committedToolKind, in: tools)
  }

  @available(
    *,
    deprecated,
    renamed: "isCommittedToolKindValid",
    message: "`selection` here means committed/base selection only, not runtime effective tool state."
  )
  public var isSelectionValid: Bool {
    isCommittedToolKindValid
  }

}

// MARK: - Equatability

extension ToolConfiguration: Equatable {

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.bindings == rhs.bindings && lhs.committedToolKind == rhs.committedToolKind
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
      Labeled("Committed Tool Kind", value: committedToolKind)
      Labeled("Spring Load Delay", value: springLoadDelay)
      Labeled("Is Committed Tool Kind Valid", value: isCommittedToolKindValid)
    }.text
  }
}
