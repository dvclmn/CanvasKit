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
  public var tools: [any CanvasTool]

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
    self.tools = Self.normalisedTools(tools)
    self.bindings = bindings
    self.selectedToolKind = selectedToolKind ?? .select
    //    self.selectedToolKind = selectedToolKind ?? self.defaultToolKind
    self.springLoadDelay = springLoadDelay
  }
}

extension ToolConfiguration {

  public static var `default`: Self { .init() }

  /// The first registered tool kind, or `select` if the catalogue is empty.
  public var defaultToolKind: CanvasToolKind {
    tools.first?.kind ?? .select
  }

  /// The registered tool for the current selection, if any.
  public var selectedTool: (any CanvasTool)? {
    tool(for: selectedToolKind)
  }

  /// The registered tool for the current selection, or a safe fallback.
  public var resolvedSelectedTool: any CanvasTool {
    selectedTool ?? tools.first ?? SelectTool()
  }

  /// All registered tools, ordered by binding appearance then remaining tools.
  public var availableTools: [any CanvasTool] {
    var seen: Set<CanvasToolKind> = []
    var result: [any CanvasTool] = []

    for binding in bindings {
      guard !seen.contains(binding.target), let tool = tool(for: binding.target) else {
        continue
      }
      seen.insert(binding.target)
      result.append(tool)
    }

    for tool in tools where !seen.contains(tool.kind) {
      seen.insert(tool.kind)
      result.append(tool)
    }

    return result
  }

  /// Returns the registered tool for the given kind, if any.
  public func tool(for kind: CanvasToolKind) -> (any CanvasTool)? {
    tools.last { $0.kind == kind }
  }

  /// Returns the first sticky shortcut for the given kind, if any.
  public func shortcut(for kind: CanvasToolKind) -> KeyboardShortcut? {
    bindings.first { $0.target == kind && $0.mode == .sticky }?.shortcut
  }

  /// Register or replace a tool by kind.
  public mutating func register(_ tool: any CanvasTool) {
    if let index = tools.firstIndex(where: { $0.kind == tool.kind }) {
      tools[index] = tool
    } else {
      tools.append(tool)
    }
  }

  /// Register or replace multiple tools by kind.
  public mutating func register(_ tools: [any CanvasTool]) {
    tools.forEach { self.register($0) }
  }

  /// Remove a registered tool by kind.
  public mutating func removeTool(kind: CanvasToolKind) {
    tools.removeAll { $0.kind == kind }
    if selectedToolKind == kind {
      selectedToolKind = tools.first?.kind ?? .select
    }
  }

  /// Replace the keyboard bindings wholesale.
  public mutating func setBindings(_ bindings: [ToolBinding]) {
    self.bindings = bindings
  }

  /// Update the committed tool selection.
  public mutating func select(_ kind: CanvasToolKind) {
    selectedToolKind = kind
  }
}

extension ToolConfiguration {

  /// A stable-ish fingerprint for SwiftUI update bookkeeping.
  /// This is intentionally implementation detail, not part of the public API.
  var fingerprint: String {
    let toolBits = tools.map { tool in
      [
        tool.kind.rawValue,
        tool.name,
        tool.icon,
        tool.dragBehaviour.name,
        tool.inputCapabilities.map(\.description).joined(separator: ","),
      ]
      .joined(separator: "|")
    }
    .joined(separator: ";")

    let bindingBits = bindings.map { binding in
      let modifiers = Modifiers(from: binding.shortcut.modifiers).rawValue
      return [
        String(describing: binding.shortcut.key),
        String(modifiers),
        binding.target.rawValue,
        String(describing: binding.mode),
      ]
      .joined(separator: "|")
    }
    .joined(separator: ";")

    return [
      selectedToolKind.rawValue,
      String(springLoadDelay),
      toolBits,
      bindingBits,
    ]
    .joined(separator: "||")
  }

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
