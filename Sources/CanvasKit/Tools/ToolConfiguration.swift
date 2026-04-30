//
//  ToolConfiguration.swift
//  CanvasKit
//
//  Created by Dave Coleman on 15/4/2026.
//

import InputPrimitives
import SwiftUI

/// Public, value-type tool state for app code.
///
/// This owns the tool catalogue, keyboard bindings, current selected tool kind,
/// and the spring-load timing policy. Keep this in app state if you want the
/// tool setup to be persisted or edited.
///
/// Registering a tool with an existing `CanvasToolKind` replaces the previous
/// tool for that kind, which makes it easy to customise built-in tools while
/// keeping their identity stable.
public struct ToolConfiguration: Sendable {

  /// The registered tools, ordered by the app's chosen preference.
  public private(set) var tools: [any CanvasTool]

  /// The key-to-tool mapping list.
  public var bindings: [ToolBinding]

  /// The user's committed tool selection.
  public var selectedToolKind: CanvasToolKind

  /// Sticky threshold for `.sticky` bindings.
  public var springLoadDelay: TimeInterval

  public init(
    tools: [any CanvasTool] = .defaultTools,
    bindings: [ToolBinding] = ToolBinding.defaultBindings(),
    selectedToolKind: CanvasToolKind? = nil,
    springLoadDelay: TimeInterval = 0.15,
  ) {
    let normalisedTools = Self.normalisedTools(tools)
    self.tools = normalisedTools
    self.bindings = bindings
    self.selectedToolKind = Self.resolvedSelection(
      selectedToolKind,
      in: normalisedTools
    )
    self.springLoadDelay = springLoadDelay
  }
}

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
extension ToolConfiguration {

  public static var `default`: Self { .init() }

  static func defaultSelection(in tools: [any CanvasTool]) -> CanvasToolKind {
    tools.first?.kind ?? .select
  }

  static func resolvedSelection(
    _ kind: CanvasToolKind?,
    in tools: [any CanvasTool],
  ) -> CanvasToolKind {
    guard let kind, containsTool(kind, in: tools) else {
      return defaultSelection(in: tools)
    }
    return kind
  }

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

  /// The first registered tool kind, or `select` if the catalogue is empty.
  public var defaultToolKind: CanvasToolKind {
    Self.defaultSelection(in: tools)
  }

  /// Whether the committed selection currently refers to a registered tool.
  public var isSelectionValid: Bool {
    Self.containsTool(selectedToolKind, in: tools)
  }

  /// The committed selection when valid, otherwise the default fallback.
  public var resolvedSelectionKind: CanvasToolKind {
    Self.resolvedSelection(selectedToolKind, in: tools)
  }

  /// Bindings whose targets do not correspond to any registered tool.
  public var invalidBindings: [ToolBinding] {
    bindings.filter { !Self.containsTool($0.target, in: tools) }
  }

  /// Bindings that are valid for the current registered tool catalogue.
  public var activeBindings: [ToolBinding] {
    bindings.filter { Self.containsTool($0.target, in: tools) }
  }

  /// Bindings that reuse an already-seen shortcut, creating precedence ties.
  public var duplicateBindings: [ToolBinding] {
    var seen: Set<KeyboardShortcut> = []
    return bindings.filter { binding in
      let wasInserted = seen.insert(binding.shortcut).inserted
      return !wasInserted
    }
  }

  /// The registered tool for the current selection, if any.
  public var selectedTool: (any CanvasTool)? {
    tool(for: selectedToolKind)
  }

  /// The registered tool for the current selection, or a safe fallback.
  public var resolvedSelectedTool: any CanvasTool {
    selectedTool ?? tools.first ?? SelectTool()
  }

  /// All registered tools, in the app's configured order.
//  public var availableTools: [any CanvasTool] {
//    tools
//  }

  /// Returns the registered tool for the given kind, if any.
  public func tool(for kind: CanvasToolKind) -> (any CanvasTool)? {
    guard let index = Self.firstIndex(of: kind, in: tools) else { return nil }
    return tools[index]
  }

  /// Returns the first sticky shortcut for the given kind, if any.
  public func shortcut(for kind: CanvasToolKind) -> KeyboardShortcut? {
    activeBindings.first { $0.target == kind && $0.mode == .sticky }?.shortcut
  }

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
}

extension ToolConfiguration {

  /// Provides similar functionality to an ordered set. Ensures
  /// Tools will display in the order they are
  /// - Tool selection fallback is the first tool in the array. Place the tool
  /// considered the 'default' first in the list, to nominate it as the fallback
  /// - Tool order in the UI is determined by array order
  ///
  private static func normalisedTools(_ tools: [any CanvasTool]) -> [any CanvasTool] {
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
