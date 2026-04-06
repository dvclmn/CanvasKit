//
//  ToolBinding.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 13/3/2026.
//

import SwiftUI

/// Maps a key input to a tool activation with a given mode and priority.
///
/// Bindings are the single source of truth for "which key activates which tool".
/// `CanvasTool` intentionally does not store shortcut keys — that's this type's job.
public struct ToolBinding: Hashable, Sendable {
  public let scope: BindingScope
  public let binding: KeyBinding
  public let target: CanvasToolKind
  public let mode: ActivationMode
  public let priority: Int

  public init(
    scope: BindingScope,
    binding: KeyBinding,
    target: CanvasToolKind,
    mode: ActivationMode,
    priority: Int = 0
  ) {
    self.scope = scope
    self.binding = binding
    self.target = target
    self.mode = mode
    self.priority = priority
  }
}

extension ToolBinding {

  /// Convenience: create a tool-scoped sticky binding (press to switch).
  public static func makeToolBinding(
    for kind: CanvasToolKind,
    key: KeyEquivalent,
    mode: ActivationMode = .sticky,
    priority: Int = 10
  ) -> Self {
    .init(
      scope: .tool(kind),
      binding: .init(key: key),
      target: kind,
      mode: mode,
      priority: priority
    )
  }

  /// Convenience: create a global hold binding (spring-load while held).
  public static func makeGlobalBinding(
    for kind: CanvasToolKind,
    key: KeyEquivalent,
    mode: ActivationMode = .hold,
    priority: Int = 100
  ) -> Self {
    .init(
      scope: .global,
      binding: .init(key: key),
      target: kind,
      mode: mode,
      priority: priority
    )
  }

  /// A minimal set of sensible defaults:
  /// - Sticky shortcuts for Select (V), Pan (H), Zoom (Z)
  /// - Global hold Space → Pan with higher priority
  public static func defaultBindings() -> [ToolBinding] {
    [
      makeToolBinding(for: .select, key: "v"),
      makeToolBinding(for: .pan, key: "h"),
      makeToolBinding(for: .zoom, key: "z"),
      makeGlobalBinding(for: .pan, key: .space),
    ]
  }
}
