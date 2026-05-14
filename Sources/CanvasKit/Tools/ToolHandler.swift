//
//  Handler+Tool.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/7/2025.
//

import InputPrimitives
import SwiftUI

/// Manages tool selection, spring-loading, and key bindings.
///
/// This is internal runtime machinery layered on top of ``ToolConfiguration``:
/// configuration describes the tool catalogue and binding policy, while the
/// handler owns committed selection, transient key-held overrides, and the
/// effective tool used to resolve canvas input right now.
@Observable
final class ToolHandler {

  var configuration: ToolConfiguration
//  var configuration: ToolConfiguration {
//    didSet { repairSelectionForCurrentConfiguration() }
//  }
  var selection: ToolSelection

  /// Active key-held overrides, most recent last.
  ///
  /// `.hold` bindings are armed immediately. `.sticky` bindings start as
  /// pending overrides so a quick key press can still commit on key-up; if held
  /// past `springLoadDelay`, they become armed spring-loads and revert on key-up.
  var overrides: [ToolOverride] = []

  private var heldKeys: Set<KeyEquivalent> = []
  private var modifiers: Modifiers = []

  init(
    configuration: ToolConfiguration = .default,
    selection: ToolSelection? = nil,
  ) {
    self.configuration = configuration
    let initialSelection = selection ?? .init(committedToolKind: configuration.defaultToolKind)
    self.selection = Self.normalisedSelection(initialSelection, for: configuration)
  }
}

// MARK: - Computed helpers
extension ToolHandler {
  public var tools: [any CanvasTool] { configuration.tools }
  public var committedToolKind: CanvasToolKind { selection.committedToolKind }
}

// MARK: - Tool
extension ToolHandler {

  /// The registered tool for the committed selection, if any.
  ///
  /// This returns `nil` only if selection has somehow drifted away from the
  /// current catalogue. Normal configuration mutations repair selection
  /// automatically.
  public var committedTool: (any CanvasTool)? {
    registeredTool(for: committedToolKind)
  }

  /// The committed tool, or a safe fallback if the committed kind is invalid.
  public var committedToolOrDefault: any CanvasTool {
    committedTool ?? tools.first ?? SelectTool()
  }

  public func registeredTool(for kind: CanvasToolKind) -> (any CanvasTool)? {
    configuration.registeredTool(for: kind)
  }
}

// MARK: - Tool Kind
extension ToolHandler {

  /// The committed tool kind if it is still registered; otherwise the default
  /// fallback tool kind.
  public var committedToolKindOrDefault: CanvasToolKind {
    configuration.containsTool(selection.committedToolKind)
      ? selection.committedToolKind
      : configuration.defaultToolKind
  }

  /// The tool used to resolve canvas input right now.
  ///
  /// This includes pending sticky shortcuts and armed spring-loads. If no
  /// key-held override is active, this falls back to ``committedToolOrDefault``.
  var effectiveTool: any CanvasTool {
    guard let last = overrides.last else { return committedToolOrDefault }
    return registeredTool(for: last.binding.target) ?? committedToolOrDefault
  }

  /// The kind of ``effectiveTool``.
  var effectiveToolKind: CanvasToolKind { effectiveTool.kind }

  /// The activation status of the currently effective key-held override.
  ///
  /// Returns `nil` when the effective tool is simply the committed tool.
  var effectiveActivationStatus: ToolActivationStatus? {
    overrides.last?.activationStatus
  }

  /// The activation status for a tool kind, if that tool currently has a
  /// key-held override in the stack.
  ///
  /// This is useful for toolbar/debug UI that wants to style individual tool
  /// buttons according to their transient activation state.
  func activationStatus(for kind: CanvasToolKind) -> ToolActivationStatus? {
    overrides.last(where: { $0.binding.target == kind })?.activationStatus
  }

  /// The most recent armed spring-loaded tool, or `nil`.
  ///
  /// Pending sticky shortcuts affect ``effectiveTool`` immediately, but do not
  /// appear here until ``armPendingSpringLoads`` marks them as armed.
  var armedSpringLoadedTool: (any CanvasTool)? {
    guard let armed = overrides.last(where: { $0.isArmed }) else { return nil }
    return registeredTool(for: armed.binding.target)
  }

  /// Whether any key-held override has crossed into armed spring-load state.
  var hasArmedSpringLoad: Bool { overrides.contains { $0.isArmed } }

  /// The smallest remaining delay before any pending `.sticky` override arms.
  ///
  /// The keyboard modifier uses this to schedule ``armPendingSpringLoads``.
  /// Returns `nil` when there are no pending sticky overrides.
  var pendingSpringLoadArmingDelay: TimeInterval? {
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
  func armPendingSpringLoads() {
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

  func setCommittedTool(_ tool: any CanvasTool) {
    configuration.register(tool)
    selection.committedToolKind = tool.kind
    overrides.removeAll()
  }

  /// Set the committed/base tool by kind, looking it up in the registry.
  func setCommittedTool(kind: CanvasToolKind) {
    guard configuration.containsTool(kind) else { return }
    selection.committedToolKind = kind
    overrides.removeAll()
  }

  @available(*, deprecated, renamed: "setCommittedTool(_:)")
  func setBaseTool(_ tool: any CanvasTool) {
    setCommittedTool(tool)
  }

  @available(*, deprecated, renamed: "setCommittedTool(kind:)")
  func setBaseTool(kind: CanvasToolKind) {
    setCommittedTool(kind: kind)
  }

  func setBindings(_ bindings: [ToolBinding]) {
    configuration.setBindings(bindings)
  }

  func registerTools(_ tools: [any CanvasTool]) {
    configuration.register(tools)
  }

  func handleKeyDown(_ key: KeyEquivalent) {
    let inserted = heldKeys.insert(key).inserted
    guard inserted else { return }

    guard let best = matchingBindings(for: key).first
    else { return }

    apply(binding: best, onKeyDown: key)
  }

  func handleKeyUp(_ key: KeyEquivalent) {
    heldKeys.remove(key)
    removeOverrides(forKey: key)
  }

  /// Clear every transient key-held override and return to the committed tool.
  func cancelAllToolOverrides() {
    overrides.removeAll()
  }

  @available(*, deprecated, renamed: "cancelAllToolOverrides()")
  func cancelAllSpringLoads() {
    cancelAllToolOverrides()
  }

  func updateModifiers(_ modifiers: Modifiers) {
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
    configuration.activeBindings
      .enumerated()
      .filter { _, binding in
        binding.shortcut.key == key && binding.modifiers.isSubset(of: modifiers)
      }
      .sorted { lhs, rhs in
        let lhsExact = lhs.element.modifiers == modifiers
        let rhsExact = rhs.element.modifiers == modifiers

        if lhsExact != rhsExact { return lhsExact }

        let lhsSpecificity = lhs.element.modifiers.rawValue.nonzeroBitCount
        let rhsSpecificity = rhs.element.modifiers.rawValue.nonzeroBitCount
        if lhsSpecificity != rhsSpecificity { return lhsSpecificity > rhsSpecificity }

        return lhs.offset < rhs.offset
      }
      .map(\.element)
  }

  private func apply(
    binding: ToolBinding,
    onKeyDown key: KeyEquivalent,
  ) {
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
    }
  }

  private func removeOverrides(forKey key: KeyEquivalent) {
    // First, determine if any sticky override should commit.
    if let override = overrides.last(where: { $0.key == key && $0.binding.mode == .sticky }) {
      if override.isArmed == false {
        // Short press: commit to the tool. This clears the override stack.
        setCommittedTool(kind: override.binding.target)
        return
      }
      // Long hold: spring-loaded only; fall through to removal to revert.
    }

    // Remove any overrides tied to this key for both hold and sticky modes.
    overrides.removeAll { $0.key == key && ($0.binding.mode == .hold || $0.binding.mode == .sticky) }
  }

  private static func normalisedSelection(
    _ selection: ToolSelection,
    for configuration: ToolConfiguration,
  ) -> ToolSelection {
    guard configuration.containsTool(selection.committedToolKind) else {
      return .init(committedToolKind: configuration.defaultToolKind)
    }
    return selection
  }

  func repairSelection(for newConfiguration: ToolConfiguration) {
    selection = Self.normalisedSelection(selection, for: newConfiguration)
    overrides.removeAll { !newConfiguration.containsTool($0.binding.target) }
  }

  var keysToWatch: Set<KeyEquivalent> {
    Set(configuration.activeBindings.map(\.shortcut.key))
  }
}

extension ToolOverride {

  var activationStatus: ToolActivationStatus {
    switch binding.mode {
      case .hold:
        return .nonCommittingHold

      case .sticky:
        return isArmed ? .springLoaded : .heldPendingCommitOrRelease
    }
  }
}
