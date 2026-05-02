//
//  Configuration+CRUD.swift
//  CanvasKit
//
//  Created by Dave Coleman on 2/5/2026.
//

extension ToolConfiguration {
  /// Register or replace a tool by kind.
  public mutating func register(_ tool: any CanvasTool) {
    if let index = Self.firstIndex(of: tool.kind, in: tools) {
      tools[index] = tool
    } else {
      tools.append(tool)
    }
  }

  /// Register or replace multiple tools by kind.
  public mutating func register(_ tools: [any CanvasTool]) {
    tools.forEach { self.register($0) }
  }

  /// Replace the registered tools wholesale, preserving the ordered-unique invariant.
  public mutating func setTools(_ tools: [any CanvasTool]) {
    self.tools = Self.normalisedTools(tools)
    selectedToolKind = Self.resolvedSelection(selectedToolKind, in: self.tools)
  }

  /// Reorder an existing tool to a new position within the catalogue.
  public mutating func moveTool(kind: CanvasToolKind, to newIndex: Int) {
    guard let currentIndex = Self.firstIndex(of: kind, in: tools) else { return }
    let tool = tools.remove(at: currentIndex)
    let clampedIndex = max(0, min(newIndex, tools.count))
    tools.insert(tool, at: clampedIndex)
  }

  /// Remove a registered tool by kind.
  public mutating func removeTool(kind: CanvasToolKind) {
    tools.removeAll { $0.kind == kind }
    if selectedToolKind == kind {
      selectedToolKind = Self.defaultSelection(in: tools)
    }
  }

  /// Replace the keyboard bindings wholesale.
  public mutating func setBindings(_ bindings: [ToolBinding]) {
    self.bindings = bindings
  }

  /// Update the committed tool selection.
  public mutating func select(_ kind: CanvasToolKind) {
    guard Self.containsTool(kind, in: tools) else { return }
    selectedToolKind = kind
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
