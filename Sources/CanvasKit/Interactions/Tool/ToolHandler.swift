//
//  Handler+Tool.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/7/2025.
//

import InteractionKit
import SwiftUI
import BasePrimitives

/// Manages tool selection, spring-loading, and key bindings.
///
/// `ToolHandler` is the single owner of "which tool is active". It manages:
/// - Base tool: The user's explicitly-selected tool (sticky/standard selection)
/// - Spring-loaded tools: Temporarily active while a key is held
/// - Effective tool: What's actually used right now (spring-load > base)
public struct ToolHandler {

  /// The user's current committed tool selection.
  private(set) public var baseTool: any CanvasTool

  /// Active spring-load / hold overrides, most recent last.
  public private(set) var overrides: [ToolOverride] = []

  /// Currently held keyboard keys.
  public private(set) var heldKeys: Set<KeyEquivalent> = []

  /// Current modifier key state.
  public private(set) var modifiers: Modifiers = []

  /// Key-to-tool mappings.
  public private(set) var bindings: [ToolBinding]

  /// All registered tools, keyed by kind.
  public private(set) var toolRegistry: [CanvasToolKind: any CanvasTool]

  /// Sticky threshold: holding a sticky key longer than this arms it as a spring-load.
  /// - For `.sticky`: If released before or equal to this delay, commit to the tool.
  ///   If held longer, treat as a transient spring-load and revert on release.
  /// - For `.hold`: Always spring-load immediately; never commit.
  /// - For `.toggle`: Commit immediately on key down.
  public var springLoadDelay: TimeInterval

  public init(
    baseTool: (any CanvasTool)? = nil,
    tools: [any CanvasTool] = .defaultTools,
    bindings: [ToolBinding] = ToolBinding.defaultBindings(),
    springLoadDelay: TimeInterval = 0.15,
  ) {
    self.baseTool = baseTool ?? tools.first ?? SelectTool()
    self.bindings = bindings
    self.toolRegistry = Dictionary(uniqueKeysWithValues: tools.map { ($0.kind, $0) })
    self.springLoadDelay = springLoadDelay
  }
}

// MARK: - Available tools (for toolbar UI)

extension ToolHandler {

  /// All registered tools, ordered by binding appearance then remaining registry entries.
  ///
  /// Use this to populate toolbar UI.
  public var availableTools: [any CanvasTool] {
    
    var seen: Set<CanvasToolKind> = []
    var result: [any CanvasTool] = []

    // Tools referenced by bindings, in binding order.
    for binding in bindings {
      guard !seen.contains(binding.target),
        let tool = toolRegistry[binding.target]
      else { continue }
      seen.insert(binding.target)
      result.append(tool)
    }

    // Remaining registered tools not covered by any binding.
    for (kind, tool) in toolRegistry where !seen.contains(kind) {
      result.append(tool)
    }

    return result
  }
}

// MARK: - Effective tool resolution

extension ToolHandler {

  /// Feeds the `activeTool` Environment value.
  /// The currently effective tool, considering pending and armed overrides.
  /// If there is any override on the stack, its tool is effective immediately.
  /// Otherwise the base tool is effective.
  public var effectiveTool: any CanvasTool {
    guard let last = overrides.last else { return baseTool }
    return resolveTool(for: last.binding.target)
  }

  /// The Kind of the effective tool
  public var toolKind: CanvasToolKind { effectiveTool.kind }

  /// The spring-loaded tool if one is armed, or `nil`.
  public var springLoadedTool: (any CanvasTool)? {
    guard let armed = overrides.last(where: { $0.isArmed }) else { return nil }
    return resolveTool(for: armed.binding.target)
  }

  public var isSpringLoaded: Bool { overrides.contains { $0.isArmed } }

  /// The smallest remaining time (in seconds) before any pending `.sticky` override arms.
  /// Returns `nil` when there are no pending arming overrides.
  public var pendingArmingTimeRemaining: TimeInterval? {
    let now = Date()
    let remainingTimes = overrides.compactMap { o -> TimeInterval? in
      guard o.binding.mode == .sticky, !o.isArmed, heldKeys.contains(o.key) else { return nil }
      let elapsed = now.timeIntervalSince(o.startedAt)
      let remaining = springLoadDelay - elapsed
      return remaining > 0 ? remaining : 0
    }
    return remainingTimes.min()
  }

  /// Arms any pending `.sticky` overrides whose hold duration has exceeded `springLoadDelay`
  /// and whose key is still held. Call this from a reactive context (e.g. a `task(id:)` or
  /// `onChange(of: overrides)`) after sleeping until the earliest pending deadline.
  public mutating func armSpringLoadsIfReady() {
    let now = Date()
    for i in overrides.indices {
      let o = overrides[i]
      guard o.binding.mode == .sticky,
        !o.isArmed,
        heldKeys.contains(o.key)
      else { continue }
      if now.timeIntervalSince(o.startedAt) >= springLoadDelay {
        overrides[i].isArmed = true
      }
    }
  }
}

// MARK: - Mutations

extension ToolHandler {

  public mutating func setBaseTool(_ tool: any CanvasTool) {
    baseTool = tool
    overrides.removeAll()
  }

  /// Set the base tool by kind, looking it up in the registry.
  public mutating func setBaseTool(kind: CanvasToolKind) {
    guard let tool = toolRegistry[kind] else { return }
    setBaseTool(tool)
  }

  public mutating func setBindings(_ bindings: [ToolBinding]) {
    self.bindings = bindings
  }

  public mutating func registerTools(_ tools: [any CanvasTool]) {
    self.toolRegistry = Dictionary(uniqueKeysWithValues: tools.map { ($0.kind, $0) })
  }

  public mutating func handleKeyDown(_ key: KeyEquivalent) {
    heldKeys.insert(key)

    guard let best = matchingBindings(for: key).first
    else { return }

    apply(binding: best, onKeyDown: key)
  }

  public mutating func handleKeyUp(_ key: KeyEquivalent) {
    heldKeys.remove(key)
    removeOverrides(forKey: key)
  }

  public mutating func cancelAllSpringLoads() {
    overrides.removeAll()
  }

  public mutating func updateModifiers(_ modifiers: Modifiers) {
    self.modifiers = modifiers
  }

  /// Returns the first shortcut key bound to the given tool kind, if any.
  ///
  /// Useful for displaying keyboard shortcuts in menus and tooltips.
//  public func shortcutKey(for kind: CanvasToolKind) -> KeyEquivalent? {
//    bindings.first { $0.target == kind && $0.mode == .sticky }?.binding.key
//  }
}

// MARK: - Private helpers

extension ToolHandler {

  private func matchingBindings(for key: KeyEquivalent) -> [ToolBinding] {
    bindings.filter { b in
      b.binding.key == key && b.binding.requiredModifiers.isSubset(of: modifiers)
    }
  }

  private mutating func apply(
    binding: ToolBinding,
    onKeyDown key: KeyEquivalent,
  ) {
    let targetTool = resolveTool(for: binding.target)
    switch binding.mode {
      case .hold:
        // Always spring-load immediately; never commit.
        let override = ToolOverride(
          binding: binding,
          startedAt: Date(),
          key: key,
          isArmed: true,
        )
        overrides.append(override)

      case .sticky:
        // Activate immediately as a pending commit; arming happens after the threshold.
        let override = ToolOverride(
          binding: binding,
          startedAt: Date(),
          key: key,
          isArmed: false,
        )
        overrides.append(override)

      case .toggle:
        // Commit immediately on key down.
        setBaseTool(targetTool)
    }
  }

  private mutating func removeOverrides(forKey key: KeyEquivalent) {
    // First, determine if any sticky override should commit.
    if let override = overrides.last(where: { $0.key == key && $0.binding.mode == .sticky }) {
      if override.isArmed == false {
        // Short press: commit to the tool. This clears the override stack.
        setBaseTool(kind: override.binding.target)
        return
      }
      // Long hold: spring-loaded only; fall through to removal to revert.
    }

    // Remove any overrides tied to this key for both hold and sticky modes.
    overrides.removeAll { $0.key == key && ($0.binding.mode == .hold || $0.binding.mode == .sticky) }
  }

  private func resolveTool(for kind: CanvasToolKind) -> any CanvasTool {
    toolRegistry[kind] ?? baseTool
  }
}
