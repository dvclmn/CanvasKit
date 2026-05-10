//
//  Tools.swift
//  CanvasKit
//
//  Created by Dave Coleman on 9/5/2026.
//

import Foundation

/// Mostly static project/app declaration.
public struct Tools: Sendable {
  public let tools: [any CanvasTool]
  public let bindings: [ToolBinding]
  public let springLoadDelay: TimeInterval

  public init(
    tools: [any CanvasTool] = .defaultTools,
    bindings: [ToolBinding] = ToolBinding.defaultBindings(),
    springLoadDelay: TimeInterval = 0.15,
  ) {
    self.tools = tools
    self.bindings = bindings
    self.springLoadDelay = springLoadDelay
  }
}

extension Tools {
  public static var `default`: Self { .init() }

  func defaultToolKind(//    in tools: [any CanvasTool]
    ) -> CanvasToolKind
  {
    tools.first?.kind ?? .select
  }

  func firstIndex(
    of kind: CanvasToolKind,
//    in tools: [any CanvasTool],
  ) -> Int? {
    tools.firstIndex { $0.kind == kind }
  }

  func containsTool(
    _ kind: CanvasToolKind
    //    in tools: [any CanvasTool],
  ) -> Bool {
    firstIndex(of: kind) != nil
  }
}

extension Tools {

  /// The committed tool, or a safe fallback if the committed kind is invalid.
  //  public var committedToolOrDefault: any CanvasTool {
  //    committedTool ?? tools.first ?? SelectTool()
  //  }

  /// Returns the registered tool for the given kind, if any.
  //  public func registeredTool(for kind: CanvasToolKind) -> (any CanvasTool)? {
  //    guard let index = Self.firstIndex(of: kind, in: tools) else { return nil }
  //    return tools[index]
  //  }
}

extension Tools {

  func committedToolKindOrDefault(
    _ kind: CanvasToolKind?
    //    in tools: [any CanvasTool],
  ) -> CanvasToolKind {
    guard let kind, containsTool(kind) else {
      return defaultToolKind()
    }
    return kind
  }

  /// Provides similar functionality to an ordered set. Ensures
  /// Tools will display in the order they are
  /// - Tool selection fallback is the first tool in the array. Place the tool
  /// considered the 'default' first in the list, to nominate it as the fallback
  /// - Tool order in the UI is determined by array order
  ///
  package static func normalisedTools(_ tools: [any CanvasTool]) -> [any CanvasTool] {
    var result: [any CanvasTool] = []
    for tool in tools {
      if let index = result.firstIndex(where: { $0.kind == tool.kind }) {
        result[index] = tool
      } else {
        result.append(tool)
      }
    }
    return result
  }
}

extension Tools {

  /// Register or replace a tool by kind.
  //  public mutating func register(_ tool: any CanvasTool) {
  //    if let index = Self.firstIndex(of: tool.kind, in: tools) {
  //      tools[index] = tool
  //    } else {
  //      tools.append(tool)
  //    }
  //  }

  /// Register or replace multiple tools by kind.
  //  public mutating func register(_ tools: [any CanvasTool]) {
  //    tools.forEach { self.register($0) }
  //  }

  /// Replace the registered tools wholesale, preserving the ordered-unique invariant.
  //  public mutating func setTools(_ tools: [any CanvasTool]) {
  //    self.tools = Self.normalisedTools(tools)
  //    committedToolKind = Self.committedToolKindOrDefault(committedToolKind, in: self.tools)
  //  }

  /// Reorder an existing tool to a new position within the catalogue.
  //  public mutating func moveTool(kind: CanvasToolKind, to newIndex: Int) {
  //    guard let currentIndex = Self.firstIndex(of: kind, in: tools) else { return }
  //    let tool = tools.remove(at: currentIndex)
  //    let clampedIndex = max(0, min(newIndex, tools.count))
  //    tools.insert(tool, at: clampedIndex)
  //  }

  /// Remove a registered tool by kind.
  //  public mutating func removeTool(kind: CanvasToolKind) {
  //    tools.removeAll { $0.kind == kind }
  //    if committedToolKind == kind {
  //      committedToolKind = Self.defaultToolKind(in: tools)
  //    }
  //  }

  /// Replace the keyboard bindings wholesale.
  //  public mutating func setBindings(_ bindings: [ToolBinding]) {
  //    self.bindings = bindings
  //  }

}
