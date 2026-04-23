//
//  Handler+Tool.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/7/2025.
//


import SwiftUI
import InputPrimitives

/// Manages tool selection, spring-loading, and key bindings.
///
/// This is internal runtime machinery. App code should work with
/// `ToolConfiguration` instead.
struct ToolHandler {

  /// Public tool configuration copied into runtime state.
  var configuration: ToolConfiguration

  /// Active spring-load / hold overrides, most recent last.
  var overrides: [ToolOverride] = []

  private var heldKeys: Set<KeyEquivalent> = []
  private var modifiers: Modifiers = []

  init(configuration: ToolConfiguration = .default) {
    self.configuration = configuration
  }
}

// MARK: - Available tools (for toolbar UI)

extension ToolHandler {

  /// All registered tools, ordered by binding appearance then remaining tools.
  var availableTools: [any CanvasTool] {
    configuration.availableTools
  }
}

// MARK: - Effective tool resolution

extension ToolHandler {

  /// The currently effective tool, considering pending and armed overrides.
  /// If there is any override on the stack, its tool is effective immediately.
  /// Otherwise the selected tool is effective.
  var effectiveTool: any CanvasTool {
    guard let last = overrides.last else { return baseTool }
    return resolveTool(for: last.binding.target)
  }

  /// The currently committed selection, excluding temporary spring-loads.
  var selectedToolKind: CanvasToolKind { configuration.selectedToolKind }

  /// The Kind of the effective tool.
  var toolKind: CanvasToolKind { effectiveTool.kind }

  /// The selected tool, or a fallback if the configured kind is not registered.
  var baseTool: any CanvasTool {
    configuration.resolvedSelectedTool
  }

  /// The spring-loaded tool if one is armed, or `nil`.
  var springLoadedTool: (any CanvasTool)? {
    guard let armed = overrides.last(where: { $0.isArmed }) else { return nil }
    return resolveTool(for: armed.binding.target)
  }

  var isSpringLoaded: Bool { overrides.contains { $0.isArmed } }

  /// The smallest remaining time (in seconds) before any pending `.sticky` override arms.
  /// Returns `nil` when there are no pending arming overrides.
  var pendingArmingTimeRemaining: TimeInterval? {
    let now = Date()
    let remainingTimes = overrides.compactMap { ovr -> TimeInterval? in
      guard ovr.binding.mode == .sticky, !ovr.isArmed, heldKeys.contains(ovr.key) else { return nil }
      let elapsed = now.timeIntervalSince(ovr.startedAt)
      let remaining = configuration.springLoadDelay - elapsed
      return remaining > 0 ? remaining : 0
    }
    return remainingTimes.min()
  }

  /// Arms any pending `.sticky` overrides whose hold duration has exceeded
  /// `springLoadDelay` and whose key is still held.
  mutating func armSpringLoadsIfReady() {
    let now = Date()
    for i in overrides.indices {
      let o = overrides[i]
      guard o.binding.mode == .sticky,
        !o.isArmed,
        heldKeys.contains(o.key)
      else { continue }
      if now.timeIntervalSince(o.startedAt) >= configuration.springLoadDelay {
        overrides[i].isArmed = true
      }
    }
  }
}

// MARK: - Mutations

extension ToolHandler {

  mutating func setBaseTool(_ tool: any CanvasTool) {
    configuration.register(tool)
    configuration.selectedToolKind = tool.kind
    overrides.removeAll()
  }

  /// Set the base tool by kind, looking it up in the registry.
  mutating func setBaseTool(kind: CanvasToolKind) {
    configuration.selectedToolKind = kind
    overrides.removeAll()
  }

  mutating func setBindings(_ bindings: [ToolBinding]) {
    configuration.setBindings(bindings)
  }

  mutating func registerTools(_ tools: [any CanvasTool]) {
    configuration.register(tools)
  }

  mutating func handleKeyDown(_ key: KeyEquivalent) {
    heldKeys.insert(key)

    guard let best = matchingBindings(for: key).first
    else { return }

    apply(binding: best, onKeyDown: key)
  }

  mutating func handleKeyUp(_ key: KeyEquivalent) {
    heldKeys.remove(key)
    removeOverrides(forKey: key)
  }

  mutating func cancelAllSpringLoads() {
    overrides.removeAll()
  }

  mutating func updateModifiers(_ modifiers: Modifiers) {
    self.modifiers = modifiers
  }

  /// Returns the first shortcut key bound to the given tool kind, if any.
  /// Useful for displaying keyboard shortcuts in menus and tooltips.
  func shortcut(for kind: CanvasToolKind) -> KeyboardShortcut? {
    configuration.shortcut(for: kind)
  }
}

// MARK: - Private helpers

extension ToolHandler {

  private func matchingBindings(for key: KeyEquivalent) -> [ToolBinding] {
    configuration.bindings.filter { binding in
      binding.shortcut.key == key && binding.modifiers.isSubset(of: modifiers)
    }
  }

  private mutating func apply(
    binding: ToolBinding,
    onKeyDown key: KeyEquivalent,
  ) {
    let targetTool = resolveTool(for: binding.target)
    switch binding.mode {
      case .hold:
        /// Always spring-load immediately; never commit.
        let override = ToolOverride(
          binding: binding,
          startedAt: Date(),
          key: key,
          isArmed: true,
        )
        overrides.append(override)

      case .sticky:
        /// Activate immediately as a pending commit; arming happens after the threshold.
        let override = ToolOverride(
          binding: binding,
          startedAt: Date(),
          key: key,
          isArmed: false,
        )
        overrides.append(override)

      case .toggle:
        /// Commit immediately on key down.
        setBaseTool(targetTool)
    }
  }

  private mutating func removeOverrides(forKey key: KeyEquivalent) {
    /// First, determine if any sticky override should commit.
    if let override = overrides.last(where: { $0.key == key && $0.binding.mode == .sticky }) {
      if override.isArmed == false {
        /// Short press: commit to the tool. This clears the override stack.
        setBaseTool(kind: override.binding.target)
        return
      }
      /// Long hold: spring-loaded only; fall through to removal to revert.
    }

    /// Remove any overrides tied to this key for both hold and sticky modes.
    overrides.removeAll { $0.key == key && ($0.binding.mode == .hold || $0.binding.mode == .sticky) }
  }

  private func resolveTool(for kind: CanvasToolKind) -> any CanvasTool {
    configuration.tool(for: kind) ?? configuration.resolvedSelectedTool
  }
  
  var keysToWatch: Set<KeyEquivalent> {
    Set(configuration.bindings.map(\.shortcut.key))
  }
}
