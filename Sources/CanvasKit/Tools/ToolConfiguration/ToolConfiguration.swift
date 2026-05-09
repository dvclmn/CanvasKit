//
//  ToolConfiguration.swift
//  CanvasKit
//
//  Created by Dave Coleman on 15/4/2026.
//

import InputPrimitives
import SwiftUI

/// Durable, value-type tool state for app code.
///
/// This owns the tool catalogue, keyboard bindings, the committed/base tool
/// kind, and the spring-load timing policy. Keep this in app state if you want
/// the tool setup to be persisted or edited.
///
/// `ToolConfiguration` deliberately does not know about transient runtime state
/// such as a Space-held Pan override. For the tool that is actually active right
/// now, ask `ToolHandler` for `effectiveTool` / `effectiveToolKind`.
///
/// Registering a tool with an existing `CanvasToolKind` replaces the previous
/// tool for that kind, which makes it easy to customise built-in tools while
/// keeping their identity stable.
struct ToolConfiguration: Sendable {

  /// The registered tools, ordered by the app's chosen preference.
  var tools: [any CanvasTool]

  /// The key-to-tool mapping list.
  var bindings: [ToolBinding]

  /// The user's committed/base tool selection.
  ///
  /// This is the persistent selection only. It does not include spring-loaded
  /// or otherwise key-held overrides. Use `ToolHandler.effectiveToolKind` for
  /// the runtime tool currently used to resolve canvas input.
  var committedToolKind: CanvasToolKind

  /// Sticky threshold for `.sticky` bindings.
  ///
  /// A `.sticky` shortcut released before this delay commits its target as the
  /// new base tool. If it remains held beyond this delay, it becomes a
  /// spring-load and reverts on release.
  var springLoadDelay: TimeInterval

  public init(
    tools: [any CanvasTool] = .defaultTools,
    bindings: [ToolBinding] = ToolBinding.defaultBindings(),
    committedToolKind: CanvasToolKind? = nil,
    springLoadDelay: TimeInterval = 0.15,
  ) {
    let normalisedTools = Self.normalisedTools(tools)
    self.tools = normalisedTools
    self.bindings = bindings
    self.committedToolKind = Self.committedToolKindOrDefault(
      committedToolKind,
      in: normalisedTools,
    )
    self.springLoadDelay = springLoadDelay
  }

  @available(
    *,
    deprecated,
    renamed: "init(tools:bindings:committedToolKind:springLoadDelay:)",
    message: "`selectedToolKind` means the committed/base selection only. Use `committedToolKind` to avoid confusing it with runtime effective tool state."
  )
  public init(
    tools: [any CanvasTool] = .defaultTools,
    bindings: [ToolBinding] = ToolBinding.defaultBindings(),
    selectedToolKind: CanvasToolKind?,
    springLoadDelay: TimeInterval = 0.15,
  ) {
    self.init(
      tools: tools,
      bindings: bindings,
      committedToolKind: selectedToolKind,
      springLoadDelay: springLoadDelay,
    )
  }
}

extension ToolConfiguration {

  public static var `default`: Self { .init() }

  static func defaultToolKind(in tools: [any CanvasTool]) -> CanvasToolKind {
    tools.first?.kind ?? .select
  }

  static func committedToolKindOrDefault(
    _ kind: CanvasToolKind?,
    in tools: [any CanvasTool],
  ) -> CanvasToolKind {
    guard let kind, containsTool(kind, in: tools) else {
      return defaultToolKind(in: tools)
    }
    return kind
  }

  /// The first registered tool kind, or `select` if the catalogue is empty.
  public var defaultToolKind: CanvasToolKind {
    Self.defaultToolKind(in: tools)
  }

  /// The committed tool kind if it is still registered; otherwise the default
  /// fallback tool kind.
  public var committedToolKindOrDefault: CanvasToolKind {
    Self.committedToolKindOrDefault(committedToolKind, in: tools)
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

  /// The registered tool for the committed selection, if any.
  ///
  /// This returns `nil` only if external code has assigned an invalid
  /// ``committedToolKind`` directly. Normal configuration mutations repair the
  /// committed kind automatically.
  public var committedTool: (any CanvasTool)? {
    registeredTool(for: committedToolKind)
  }

  /// The committed tool, or a safe fallback if the committed kind is invalid.
  public var committedToolOrDefault: any CanvasTool {
    committedTool ?? tools.first ?? SelectTool()
  }

  /// Returns the registered tool for the given kind, if any.
  public func registeredTool(for kind: CanvasToolKind) -> (any CanvasTool)? {
    guard let index = Self.firstIndex(of: kind, in: tools) else { return nil }
    return tools[index]
  }

  @available(
    *,
    deprecated,
    renamed: "committedToolKind",
    message: "`selectedToolKind` is committed/base state only. Use `committedToolKind`, or ask `ToolHandler.effectiveToolKind` for runtime state."
  )
  public var selectedToolKind: CanvasToolKind {
    get { committedToolKind }
    set { committedToolKind = newValue }
  }

  @available(
    *,
    deprecated,
    renamed: "committedToolKindOrDefault",
    message: "This is still committed/base state only; it does not include spring-loaded overrides."
  )
  public var resolvedSelectionKind: CanvasToolKind {
    committedToolKindOrDefault
  }

  @available(
    *,
    deprecated,
    renamed: "committedTool",
    message: "`selectedTool` is committed/base state only. Use `committedTool`, or ask `ToolHandler.effectiveTool` for runtime state."
  )
  public var selectedTool: (any CanvasTool)? {
    committedTool
  }

  @available(
    *,
    deprecated,
    renamed: "committedToolOrDefault",
    message: "This is still committed/base state only; it does not include spring-loaded overrides."
  )
  public var resolvedSelectedTool: any CanvasTool {
    committedToolOrDefault
  }

  @available(
    *,
    deprecated,
    renamed: "registeredTool(for:)",
    message: "Use `registeredTool(for:)` to make it clear this is a catalogue lookup, not runtime tool resolution."
  )
  public func tool(for kind: CanvasToolKind) -> (any CanvasTool)? {
    registeredTool(for: kind)
  }

  /// Returns the first sticky shortcut for the given kind, if any.
  public func shortcut(for kind: CanvasToolKind) -> KeyboardShortcut? {
    activeBindings.first { $0.target == kind && $0.mode == .sticky }?.shortcut
  }
}
