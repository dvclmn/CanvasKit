//
//  ToolConfiguration.swift
//  CanvasKit
//
//  Created by Dave Coleman on 15/4/2026.
//

private import ViewTools
import SwiftUI

/// Durable, value-type tool catalogue for app code.
///
/// This owns the registered tools, keyboard bindings, and spring-load timing
/// policy. Keep this in app state if you want the tool setup to be persisted
/// or edited.
///
/// `ToolConfiguration` deliberately does not know about transient runtime state
/// such as the committed selection or a Space-held Pan override. For the
/// committed selection, ask `ToolHandler` / ``ToolSelection``. For the tool
/// that is actually active right now, ask `ToolHandler` for `effectiveTool` /
/// `effectiveToolID`.
///
/// Registering a tool with an existing `CanvasToolID` replaces the previous
/// tool for that ID, which makes it easy to customise built-in tools while
/// keeping their identity stable.
public struct ToolConfiguration: Sendable {

  /// The registered tools, ordered by the app's chosen preference.
  public var tools: [any CanvasTool]

  /// The key-to-tool mapping list.
  public var bindings: [ToolBinding]

  /// Sticky threshold for `.sticky` bindings.
  ///
  /// A `.sticky` shortcut released before this delay commits its target as the
  /// new base tool. If it remains held beyond this delay, it becomes a
  /// spring-load and reverts on release.
  public var springLoadDelay: TimeInterval

  public init(
    tools: [any CanvasTool] = .defaultTools,
    bindings: [ToolBinding] = ToolBinding.defaultBindings(),
    springLoadDelay: TimeInterval = 0.15,
  ) {
    self.tools = Self.normalisedTools(tools)
    self.bindings = bindings
    self.springLoadDelay = springLoadDelay
  }
}

extension ToolConfiguration {

  public static var `default`: Self { .init() }

  /// The first registered tool id, or `select` if the catalogue is empty.
  public var defaultToolID: CanvasToolID {
    tools.first?.id ?? .select
  }

  /// Returns the registered tool for the given id, if any.
  public func registeredTool(for id: CanvasToolID) -> (any CanvasTool)? {
    guard let index = firstIndex(of: id) else { return nil }
    return tools[index]
  }

  /// Whether the catalogue contains a tool with the given id.
  public func containsTool(_ id: CanvasToolID) -> Bool {
    firstIndex(of: id) != nil
  }

  func firstIndex(of id: CanvasToolID) -> Int? {
    tools.firstIndex { $0.id == id }
  }

  /// Bindings whose targets do not correspond to any registered tool.
  public var invalidBindings: [ToolBinding] {
    bindings.filter { !containsTool($0.target) }
  }

  /// Bindings that are valid for the current registered tool catalogue.
  public var activeBindings: [ToolBinding] {
    bindings.filter { containsTool($0.target) }
  }

  /// Bindings that reuse an already-seen shortcut, creating precedence ties.
  public var duplicateBindings: [ToolBinding] {
    var seen: Set<KeyboardShortcut> = []
    return bindings.filter { binding in
      let wasInserted = seen.insert(binding.shortcut).inserted
      return !wasInserted
    }
  }

  @available(
    *,
    deprecated,
    renamed: "registeredTool(for:)",
    message: "Use `registeredTool(for:)` to make it clear this is a catalogue lookup, not runtime tool resolution."
  )
  public func tool(for id: CanvasToolID) -> (any CanvasTool)? {
    registeredTool(for: id)
  }

  /// Returns the first sticky shortcut for the given id, if any.
  public func shortcut(for id: CanvasToolID) -> KeyboardShortcut? {
    activeBindings.first { $0.target == id && $0.mode == .sticky }?.shortcut
  }
}
