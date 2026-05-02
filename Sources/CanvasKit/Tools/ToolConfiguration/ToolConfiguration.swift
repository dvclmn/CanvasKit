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
  public package(set) var tools: [any CanvasTool]

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
      in: normalisedTools,
    )
    self.springLoadDelay = springLoadDelay
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

  /// The first registered tool kind, or `select` if the catalogue is empty.
  public var defaultToolKind: CanvasToolKind {
    Self.defaultSelection(in: tools)
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

  /// Returns the registered tool for the given kind, if any.
  public func tool(for kind: CanvasToolKind) -> (any CanvasTool)? {
    guard let index = Self.firstIndex(of: kind, in: tools) else { return nil }
    return tools[index]
  }

  /// Returns the first sticky shortcut for the given kind, if any.
  public func shortcut(for kind: CanvasToolKind) -> KeyboardShortcut? {
    activeBindings.first { $0.target == kind && $0.mode == .sticky }?.shortcut
  }
}
