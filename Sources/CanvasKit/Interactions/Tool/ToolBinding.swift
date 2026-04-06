//
//  ToolBinding.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 13/3/2026.
//

import SwiftUI

/// Maps a key input to a tool activation with a given mode.
///
/// Bindings are the single source of truth for "which key activates which tool".
/// `CanvasTool` intentionally does not store shortcut keys — that's this type's job.
///
/// A single tool can have multiple bindings (e.g. Pan has both "H" sticky and Space hold).
public struct ToolBinding: Hashable, Sendable {
  public let binding: KeyBinding
  public let target: CanvasToolKind
  public let mode: ActivationMode

  public init(
    binding: KeyBinding,
    target: CanvasToolKind,
    mode: ActivationMode
  ) {
    self.binding = binding
    self.target = target
    self.mode = mode
  }
}

extension ToolBinding {

  /// A minimal set of sensible defaults:
  /// - Sticky shortcuts for Select (V), Pan (H), Zoom (Z)
  /// - Hold Space → spring-load Pan from any tool
  public static func defaultBindings() -> [ToolBinding] {
    [
      .init(binding: .init(key: "v"), target: .select, mode: .sticky),
      .init(binding: .init(key: "h"), target: .pan, mode: .sticky),
      .init(binding: .init(key: "z"), target: .zoom, mode: .sticky),
      .init(binding: .init(key: .space), target: .pan, mode: .hold),
    ]
  }
}
