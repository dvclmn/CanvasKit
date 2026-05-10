//
//  Configuration+CRUD.swift
//  CanvasKit
//
//  Created by Dave Coleman on 2/5/2026.
//

extension ToolConfiguration {

  /// Provides ordered-set behaviour for tools.
  ///
  /// The first occurrence keeps its display order. Later tools with the same
  /// kind replace that slot's value, which allows built-ins to be customised
  /// without changing toolbar ordering.
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

  /// Register or replace a tool by kind.
  public mutating func register(_ tool: any CanvasTool) {
    if let index = firstIndex(of: tool.kind) {
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
  }

  /// Reorder an existing tool to a new position within the catalogue.
  public mutating func moveTool(kind: CanvasToolKind, to newIndex: Int) {
    guard let currentIndex = firstIndex(of: kind) else { return }
    let tool = tools.remove(at: currentIndex)
    let clampedIndex = max(0, min(newIndex, tools.count))
    tools.insert(tool, at: clampedIndex)
  }

  /// Remove a registered tool by kind.
  public mutating func removeTool(kind: CanvasToolKind) {
    tools.removeAll { $0.kind == kind }
  }

  /// Replace the keyboard bindings wholesale.
  public mutating func setBindings(_ bindings: [ToolBinding]) {
    self.bindings = bindings
  }
}
